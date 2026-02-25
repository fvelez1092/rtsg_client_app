import 'dart:async';
import 'package:app_rtsg_client/data/models/trip_model.dart';
import 'package:app_rtsg_client/data/models/trip_status.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:app_rtsg_client/data/services/gps_service.dart';
import 'package:app_rtsg_client/data/services/mapbox_service.dart';
import 'package:app_rtsg_client/data/services/trip_simulator_service.dart';

class TripController extends GetxController {
  final MapboxGeocoder _geocoder;
  final GpsService _gps = Get.find<GpsService>();
  final TripSimulatorService _sim = Get.find<TripSimulatorService>();

  TripController({MapboxGeocoder? geocoder})
    : _geocoder = geocoder ?? MapboxGeocoder();

  // ---------------- ORIGEN (setea HomeController) ----------------
  final RxString originAddress = ''.obs;
  final Rx<LatLng?> originLatLng = Rx<LatLng?>(null);

  void setOrigin({required String address, required LatLng point}) {
    originAddress.value = address;
    originLatLng.value = point;

    if (destinationLatLng.value != null) {
      recalculateIfPossible();
    }
  }

  // ---------------- DESTINO ----------------
  final RxString destinationAddress = ''.obs;
  final Rx<LatLng?> destinationLatLng = Rx<LatLng?>(null);

  // ---------------- SEARCH (sheet) ----------------
  final TextEditingController searchCtrl = TextEditingController();
  final RxBool isSearching = false.obs;
  final RxList<Map<String, dynamic>> results = <Map<String, dynamic>>[].obs;

  Timer? _debounce;
  int _reqId = 0;

  int limit = 6;
  double maxDistanceKm = 50;
  String country = 'ec';

  LatLng? get _userPos => _gps.currentPosition.value;

  void openDestinationSheet() {
    searchCtrl.clear();
    results.clear();
    isSearching.value = false;
  }

  void onQueryChanged(String value) {
    _debounce?.cancel();

    final q = value.trim();
    if (q.isEmpty) {
      results.clear();
      isSearching.value = false;
      return;
    }

    isSearching.value = true;

    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final currentReq = ++_reqId;
      final pos = _userPos;

      final list = await _geocoder.search(
        query: q,
        userLat: pos?.latitude,
        userLon: pos?.longitude,
        limit: limit,
        maxDistanceKm: maxDistanceKm,
        country: country,
      );

      if (currentReq != _reqId) return;

      results.assignAll(list);
      isSearching.value = false;
    });
  }

  Future<void> selectDestination(Map<String, dynamic> s) async {
    final name = (s['display_name'] ?? '').toString();
    final lat = (s['lat'] as num?)?.toDouble();
    final lon = (s['lon'] as num?)?.toDouble();
    final point = (lat != null && lon != null) ? LatLng(lat, lon) : null;

    destinationAddress.value = name;
    destinationLatLng.value = point;

    results.clear();
    isSearching.value = false;

    await recalculateIfPossible();
  }

  // ---------------- RUTA / DIST / TIEMPO / TARIFA ----------------
  final RxBool isCalculating = false.obs;

  final RxDouble distanceKm = 0.0.obs;
  final RxInt durationMin = 0.obs;
  final RxList<LatLng> routePoints = <LatLng>[].obs;

  final RxDouble estimatedFare = 0.0.obs;

  double baseFare = 1.00;
  double perKm = 0.60;
  double perMin = 0.05;

  Future<void> recalculateIfPossible() async {
    final origin = originLatLng.value;
    final dest = destinationLatLng.value;
    if (origin == null || dest == null) return;

    isCalculating.value = true;

    try {
      final res = await _geocoder.route(
        origin: origin,
        destination: dest,
        profile: 'driving',
      );

      if (res == null) {
        distanceKm.value = 0;
        durationMin.value = 0;
        routePoints.clear();
        estimatedFare.value = 0;
        return;
      }

      final dMeters = (res['distance_m'] as num?)?.toDouble() ?? 0.0;
      final dSeconds = (res['duration_s'] as num?)?.toDouble() ?? 0.0;
      final pts = (res['points'] as List?)?.cast<LatLng>() ?? <LatLng>[];

      distanceKm.value = dMeters / 1000.0;
      durationMin.value = (dSeconds / 60.0).round();
      routePoints.assignAll(pts);

      estimatedFare.value = _calcFare(distanceKm.value, durationMin.value);
    } finally {
      isCalculating.value = false;
    }
  }

  double _calcFare(double km, int min) {
    final fare = baseFare + (km * perKm) + (min * perMin);
    return (fare * 100).roundToDouble() / 100.0;
  }

  bool get canCreateTrip {
    final originOk =
        originLatLng.value != null && originAddress.value.trim().isNotEmpty;
    final destOk =
        destinationLatLng.value != null &&
        destinationAddress.value.trim().isNotEmpty;
    final routeOk = distanceKm.value > 0 && durationMin.value > 0;
    final notBusy = status.value == TripStatus.idle;
    return originOk && destOk && routeOk && !isCalculating.value && notBusy;
  }

  // ---------------- ESTADOS DE CARRERA ----------------
  final Rx<TripStatus> status = TripStatus.idle.obs;
  final Rx<TripModel?> activeTrip = Rx<TripModel?>(null);

  StreamSubscription<TripModel>? _sub;

  Future<void> createTrip() async {
    if (!canCreateTrip) return;

    final origin = originLatLng.value!;
    final dest = destinationLatLng.value!;

    status.value = TripStatus.creating;

    final model = TripModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      origin: origin,
      originName: originAddress.value,
      destination: dest,
      destinationName: destinationAddress.value,
      distanceKm: distanceKm.value,
      durationMin: durationMin.value,
      fare: estimatedFare.value,
      status: TripStatus.creating,
    );

    // Suscripción a eventos (una sola)
    _sub?.cancel();
    _sub = _sim.stream.listen((trip) {
      // Solo procesa si es el mismo id
      final current = activeTrip.value;
      if (current == null) return;
      if (trip.id != current.id) return;

      activeTrip.value = trip;
      status.value = trip.status;
    });

    try {
      final created = await _sim.createTrip(model);
      activeTrip.value = created;
      status.value = created.status;
    } catch (_) {
      status.value = TripStatus.failed;
    }
  }

  void cancelTrip() {
    _sim.cancelActive();
    status.value = TripStatus.cancelled;
    activeTrip.value = null;

    // volver a estado idle y limpiar (si quieres mantener el destino, dime)
    resetTrip();
    status.value = TripStatus.idle;
  }

  void resetTrip() {
    destinationAddress.value = '';
    destinationLatLng.value = null;

    distanceKm.value = 0;
    durationMin.value = 0;
    routePoints.clear();
    estimatedFare.value = 0;

    results.clear();
    isSearching.value = false;
    searchCtrl.clear();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    _sub?.cancel();
    searchCtrl.dispose();
    _geocoder.dispose();
    super.onClose();
  }
}
