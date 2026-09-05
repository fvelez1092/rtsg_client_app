import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:app_rtsg_client/data/models/trip_model.dart';
import 'package:app_rtsg_client/data/models/trip_status.dart';
import 'package:app_rtsg_client/data/services/gps_service.dart';
import 'package:app_rtsg_client/data/services/mapbox_service.dart';
import 'package:app_rtsg_client/data/services/trip_simulator_service.dart';

class TripController extends GetxController {
  final MapboxGeocoder _geocoder;
  final GpsService _gps = Get.find<GpsService>();
  final TripSimulatorService _sim = Get.find<TripSimulatorService>();

  TripController({MapboxGeocoder? geocoder})
      : _geocoder = geocoder ?? MapboxGeocoder();

  // ---------------- MAPA / ORIGEN ----------------
  final RxString centerLabel = 'Buscando ubicación…'.obs;
  final RxBool isResolvingOrigin = false.obs;

  final RxString originAddress = ''.obs;
  final Rx<LatLng?> originLatLng = Rx<LatLng?>(null);

  LatLng lastCenter = const LatLng(-0.18065, -78.46783);
  int _originReqId = 0;
  bool _originWasSelectedManually = false;
  Worker? _gpsWorker;

  @override
  void onInit() {
    super.onInit();

    final gpsPos = _gps.currentPosition.value;
    if (gpsPos != null) {
      lastCenter = gpsPos;
      _resolveOriginAddress(gpsPos);
    }

    _gpsWorker = ever<LatLng?>(_gps.currentPosition, (pos) {
      if (pos == null ||
          _originWasSelectedManually ||
          destinationLatLng.value != null ||
          status.value != TripStatus.idle) {
        return;
      }

      lastCenter = pos;
      _resolveOriginAddress(pos);
    });
  }

  void setOrigin({required String address, required LatLng point}) {
    originAddress.value = address;
    originLatLng.value = point;

    if (destinationLatLng.value != null) {
      recalculateIfPossible();
    }
  }

  void onMapChanged(LatLng center, double zoom, {required bool isFinal}) {
    if (destinationLatLng.value != null || status.value != TripStatus.idle) {
      return;
    }

    lastCenter = center;
    _originWasSelectedManually = true;

    if (!isFinal) {
      _originReqId++;
      centerLabel.value = 'Buscando dirección…';
      isResolvingOrigin.value = true;
      return;
    }

    _resolveOriginAddress(center);
  }

  void setOriginFromExternal({
    required LatLng point,
    required String address,
  }) {
    _originReqId++;
    _originWasSelectedManually = true;
    lastCenter = point;
    centerLabel.value = address;
    isResolvingOrigin.value = false;
    setOrigin(address: address, point: point);
  }

  Future<bool> useCurrentLocation() async {
    var position = _gps.currentPosition.value;

    if (position == null) {
      await _gps.getCurrentLocation();
      position = _gps.currentPosition.value;
    }

    if (position == null) return false;

    _originWasSelectedManually = false;
    lastCenter = position;
    await _resolveOriginAddress(position);
    return true;
  }

  Future<void> _resolveOriginAddress(LatLng center) async {
    final currentReq = ++_originReqId;
    isResolvingOrigin.value = true;

    try {
      final placeName = await _geocoder.reverse(
        lat: center.latitude,
        lon: center.longitude,
      );

      if (currentReq != _originReqId) return;

      final resolved = placeName ?? 'Dirección no disponible';
      centerLabel.value = resolved;
      setOrigin(address: resolved, point: center);
    } catch (_) {
      if (currentReq != _originReqId) return;
      centerLabel.value = 'Dirección no disponible';
    } finally {
      if (currentReq == _originReqId) {
        isResolvingOrigin.value = false;
      }
    }
  }

  // ---------------- DESTINO ----------------
  final RxString destinationAddress = ''.obs;
  final Rx<LatLng?> destinationLatLng = Rx<LatLng?>(null);

  // ---------------- SEARCH ----------------
  final TextEditingController searchCtrl = TextEditingController();
  final RxBool isSearching = false.obs;
  final RxList<Map<String, dynamic>> results = <Map<String, dynamic>>[].obs;

  Timer? _debounce;
  int _searchReqId = 0;

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
      final currentReq = ++_searchReqId;
      final pos = _userPos;

      final list = await _geocoder.search(
        query: q,
        userLat: pos?.latitude,
        userLon: pos?.longitude,
        limit: limit,
        maxDistanceKm: maxDistanceKm,
        country: country,
      );

      if (currentReq != _searchReqId) return;

      results.assignAll(list);
      isSearching.value = false;
    });
  }

  Future<void> selectDestination(Map<String, dynamic> result) async {
    final name = (result['display_name'] ?? '').toString();
    final lat = (result['lat'] as num?)?.toDouble();
    final lon = (result['lon'] as num?)?.toDouble();
    final point = (lat != null && lon != null) ? LatLng(lat, lon) : null;

    destinationAddress.value = name;
    destinationLatLng.value = point;

    results.clear();
    isSearching.value = false;

    await recalculateIfPossible();
  }

  Future<void> setDestination({
    required String address,
    required LatLng point,
  }) async {
    destinationAddress.value = address;
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

    _sub?.cancel();
    _sub = _sim.stream.listen((trip) {
      final current = activeTrip.value;
      if (current == null || trip.id != current.id) return;

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
    _gpsWorker?.dispose();
    _debounce?.cancel();
    _sub?.cancel();
    searchCtrl.dispose();
    _geocoder.dispose();
    super.onClose();
  }
}
