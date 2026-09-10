import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:app_rtsg_client/data/models/trip_model.dart';
import 'package:app_rtsg_client/data/models/trip_status.dart';
import 'package:app_rtsg_client/data/models/request/trip_request.dart';
import 'package:app_rtsg_client/data/models/saved_address_model.dart';
import 'package:app_rtsg_client/data/services/gps_service.dart';
import 'package:app_rtsg_client/data/services/mapbox_service.dart';
import 'package:app_rtsg_client/data/services/trip_service.dart';
import 'package:app_rtsg_client/global_memory.dart';

enum TripCategory { normal, vip }

class TripController extends GetxController {
  final MapboxGeocoder _geocoder;
  final GpsService _gps = Get.find<GpsService>();
  final TripService _tripService = Get.find<TripService>();

  TripController({MapboxGeocoder? geocoder})
    : _geocoder = geocoder ?? MapboxGeocoder();

  final RxString centerLabel = 'Buscando ubicación…'.obs;
  final RxBool isResolvingOrigin = false.obs;
  final RxString originAddress = ''.obs;
  final Rx<LatLng?> originLatLng = Rx<LatLng?>(null);
  final TextEditingController exactLocationCtrl = TextEditingController();
  int? selectedOriginAddressId;
  int? selectedOriginBaseId;

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
    selectedOriginAddressId = null;
    selectedOriginBaseId = null;
    exactLocationCtrl.clear();
    originAddress.value = address;
    originLatLng.value = point;
    if (destinationLatLng.value != null) recalculateIfPossible();
  }

  void setOriginFromSavedAddress(SavedAddress address) {
    final point = address.point;
    if (point == null) return;

    _originReqId++;
    _originWasSelectedManually = true;
    lastCenter = point;
    centerLabel.value = address.address;
    isResolvingOrigin.value = false;
    originAddress.value = address.address;
    originLatLng.value = point;
    selectedOriginAddressId = address.id;
    selectedOriginBaseId = address.baseId;
    exactLocationCtrl.text = address.exactLocation;

    if (destinationLatLng.value != null) recalculateIfPossible();
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

  void setOriginFromExternal({required LatLng point, required String address}) {
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
      if (currentReq == _originReqId) isResolvingOrigin.value = false;
    }
  }

  final RxString destinationAddress = ''.obs;
  final Rx<LatLng?> destinationLatLng = Rx<LatLng?>(null);

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

  final RxBool isCalculating = false.obs;
  final RxDouble distanceKm = 0.0.obs;
  final RxInt durationMin = 0.obs;
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final RxDouble estimatedFare = 0.0.obs;

  double baseFare = 1.00;
  double perKm = 0.60;
  double perMin = 0.05;

  final Rx<TripCategory> selectedCategory = TripCategory.normal.obs;
  final RxDouble priceBoost = 0.0.obs;
  double vipMultiplier = 1.30;

  static const List<double> priceBoostOptions = <double>[0.0, 0.50, 1.00, 2.00];

  void selectCategory(TripCategory category) {
    if (selectedCategory.value == category) return;
    selectedCategory.value = category;
    distanceKm.refresh();
  }

  void setPriceBoost(double amount) {
    if (amount < 0) return;
    final next = _roundMoney(amount);
    if (priceBoost.value == next) return;
    priceBoost.value = next;
    distanceKm.refresh();
  }

  double get normalFare => _roundMoney(estimatedFare.value);
  double get vipFare => _roundMoney(estimatedFare.value * vipMultiplier);
  double get categoryFare =>
      selectedCategory.value == TripCategory.vip ? vipFare : normalFare;
  double get finalFare => _roundMoney(categoryFare + priceBoost.value);

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

  double _calcFare(double km, int min) =>
      _roundMoney(baseFare + (km * perKm) + (min * perMin));

  double _roundMoney(double value) => (value * 100).roundToDouble() / 100.0;

  bool get canCreateTrip {
    final originOk =
        originLatLng.value != null && originAddress.value.trim().isNotEmpty;
    final destOk =
        destinationLatLng.value != null &&
        destinationAddress.value.trim().isNotEmpty;
    final routeOk = distanceKm.value > 0 && durationMin.value > 0;
    return originOk &&
        destOk &&
        routeOk &&
        !isCalculating.value &&
        status.value == TripStatus.idle;
  }

  final Rx<TripStatus> status = TripStatus.idle.obs;
  final Rx<TripModel?> activeTrip = Rx<TripModel?>(null);
  final RxBool isCreatingTrip = false.obs;
  bool _createTripInFlight = false;

  Future<void> createTrip() async {
    if (_createTripInFlight || !canCreateTrip) return;

    _createTripInFlight = true;
    isCreatingTrip.value = true;

    try {
      final user = GlobalMemory.to.user;
      final clienteId = user?.idPerson;
      final usuarioId = user?.idUser;
      final telefono = (user?.cellphone ?? '').trim();

      if (clienteId == null || usuarioId == null || telefono.isEmpty) {
        status.value = TripStatus.failed;
        return;
      }

      status.value = TripStatus.creating;

      final origin = originLatLng.value!;

      final request = TripRequest(
        boot: false,
        telefonoCliente: telefono,
        clienteId: clienteId,
        direccionPartida: originAddress.value,
        ubicacionExactaCliente: exactLocationCtrl.text.trim(),
        latitudPartida: origin.latitude,
        longitudPartida: origin.longitude,
        personaDireccionId: selectedOriginAddressId,
        baseId: selectedOriginBaseId,
        estadoCarrera: 'O',
        unidadId: '0',
        usuarioId: usuarioId,
      );

      final created = await _tripService.createTrip(request);

      activeTrip.value = TripModel(
        id: created.idTravelRequest.toString(),
        origin: originLatLng.value!,
        originName: created.departureAddress.isNotEmpty
            ? created.departureAddress
            : originAddress.value,
        destination: destinationLatLng.value!,
        destinationName: created.destinationAddress.isNotEmpty
            ? created.destinationAddress
            : destinationAddress.value,
        distanceKm: created.distanceKm.toDouble() > 0
            ? created.distanceKm.toDouble()
            : distanceKm.value,
        durationMin: created.estimatedTime.inMinutes > 0
            ? created.estimatedTime.inMinutes
            : durationMin.value,
        fare: created.cost.toDouble() > 0 ? created.cost.toDouble() : finalFare,
        status: TripStatus.searching,
      );

      status.value = TripStatus.searching;
    } catch (e) {
      status.value = TripStatus.failed;
      activeTrip.value = null;
    } finally {
      _createTripInFlight = false;
      isCreatingTrip.value = false;
    }
  }

  void cancelTrip() {
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
    selectedCategory.value = TripCategory.normal;
    priceBoost.value = 0;
    results.clear();
    isSearching.value = false;
    searchCtrl.clear();
    exactLocationCtrl.clear();
    selectedOriginAddressId = null;
    selectedOriginBaseId = null;
  }

  @override
  void onClose() {
    _gpsWorker?.dispose();
    _debounce?.cancel();
    searchCtrl.dispose();
    exactLocationCtrl.dispose();
    _geocoder.dispose();
    super.onClose();
  }
}
