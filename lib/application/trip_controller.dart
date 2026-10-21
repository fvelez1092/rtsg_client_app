import 'package:app_rtsg_client/data/models/tariff_configuration.dart';
import 'package:app_rtsg_client/data/services/tariff_configuration_service.dart';
import 'package:app_rtsg_client/data/services/trip_diagnostics.dart';
import 'package:app_rtsg_client/data/models/trip_number.dart';
import 'package:app_rtsg_client/application/trips_controller.dart';
import 'package:app_rtsg_client/data/models/trip_state_contract.dart';
import 'package:app_rtsg_client/data/services/active_trip_session.dart';
import 'dart:async';
import 'dart:convert';

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
import 'package:app_rtsg_client/data/services/trip_socket_service.dart';
import 'package:app_rtsg_client/global_memory.dart';
import 'package:app_rtsg_client/presentation/pages/trip/components/searching_driver_dialog.dart';

enum TripCategory { normal, vip }

class TripController extends GetxController {
  final MapboxGeocoder _geocoder;
  final GpsService _gps = Get.find<GpsService>();
  final TripService _tripService = Get.find<TripService>();
  final TripSocketService _tripSocket = Get.find<TripSocketService>();
  StreamSubscription<Map<String, dynamic>>? _assignmentSubscription;
  StreamSubscription<Map<String, dynamic>>? _locationSubscription;
  StreamSubscription<String>? _socketErrorSubscription;
  StreamSubscription<Map<String, dynamic>>? _stateSubscription;
  Worker? _statusWorker;
  bool _searchDialogVisible = false;
  final RxBool isRecoveringTrip = false.obs;
  final RxString recoveryError = ''.obs;
  Timer? _recoveryTimeout;

  TripController({
    MapboxGeocoder? geocoder,
    TariffConfigurationService? tariffService,
    DateTime Function()? now,
  }) : _geocoder = geocoder ?? MapboxGeocoder(),
       _tariffService = tariffService ?? TariffConfigurationService(),
       _now = now ?? DateTime.now;

  final TariffConfigurationService _tariffService;
  final DateTime Function() _now;
  final Rxn<TariffConfiguration> tariffConfiguration =
      Rxn<TariffConfiguration>();

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

    _assignmentSubscription = _tripSocket.assignments.listen(_onAssignment);
    _locationSubscription = _tripSocket.locations.listen(_onLocation);
    _socketErrorSubscription = _tripSocket.errors.listen((message) {
      if (isRecoveringTrip.value) {
        recoveryError.value = message;
        isRecoveringTrip.value = false;
        _recoveryTimeout?.cancel();
      }
      Get.snackbar(
        'Conexión de carrera',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
    });
    _stateSubscription = _tripSocket.statusUpdates.listen(_onAssignment);
    _statusWorker = ever<TripStatus>(status, _handleStatusChange);

    final savedTrip = ActiveTripSession.instance.trip.value;
    if (savedTrip != null) {
      activeTrip.value = savedTrip;
      originLatLng.value = savedTrip.origin;
      originAddress.value = savedTrip.originName;
      destinationLatLng.value = savedTrip.destination;
      destinationAddress.value = savedTrip.destinationName;
      lastCenter = savedTrip.origin;
      driverPosition.value = ActiveTripSession.instance.driverPosition;
      distanceKm.value = savedTrip.distanceKm;
      durationMin.value = savedTrip.durationMin;
      estimatedFare.value = savedTrip.fare;
      status.value = savedTrip.status;
      _tripSocket.listenForTrip(savedTrip.id);
    }

    final args = Get.arguments;
    final assignedTripId = args is Map
        ? int.tryParse((args['assignedTripId'] ?? '').toString())
        : null;
    if (assignedTripId != null && assignedTripId > 0) {
      recoverAssignedTrip(assignedTripId);
    }

    final gpsPos = _gps.currentPosition.value;
    if (gpsPos != null && status.value == TripStatus.idle) {
      lastCenter = gpsPos;
      _resolveOriginAddress(gpsPos);
    }

    _tripSocket.connect();

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
    final originName = address.address.trim().isNotEmpty
        ? address.address
        : address.label;
    centerLabel.value = originName;
    isResolvingOrigin.value = false;
    originAddress.value = originName;
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

    // Guarda el punto final inmediatamente e invalida la dirección anterior.
    // Así nunca se puede crear una carrera mezclando el nuevo centro del mapa
    // con la dirección o las coordenadas de una selección previa.
    selectedOriginAddressId = null;
    selectedOriginBaseId = null;
    exactLocationCtrl.clear();
    originLatLng.value = center;
    originAddress.value = '';
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
    originLatLng.value = center;
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
      originAddress.value = 'Ubicación seleccionada en el mapa';
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
  final RxString routeError = ''.obs;
  final RxBool tariffUnavailable = false.obs;
  int _routeReqId = 0;
  final RxDouble distanceKm = 0.0.obs;
  final RxInt durationMin = 0.obs;
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final RxDouble estimatedFare = 0.0.obs;

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

    final request = ++_routeReqId;
    isCalculating.value = true;
    routeError.value = '';
    tariffUnavailable.value = false;
    tariffConfiguration.value = null;
    distanceKm.value = 0;
    durationMin.value = 0;
    routePoints.clear();
    estimatedFare.value = 0;
    try {
      final res = await _geocoder.route(
        origin: origin,
        destination: dest,
        profile: 'driving',
      );

      if (request != _routeReqId || isClosed) return;
      if (res == null) {
        routeError.value =
            'No pudimos calcular la ruta. Revisa tu conexión y vuelve a intentarlo.';
        distanceKm.value = 0;
        durationMin.value = 0;
        routePoints.clear();
        estimatedFare.value = 0;
        return;
      }

      final dMeters = (res['distance_m'] as num?)?.toDouble() ?? 0.0;
      final dSeconds = (res['duration_s'] as num?)?.toDouble() ?? 0.0;
      final pts = (res['points'] as List?)?.cast<LatLng>() ?? <LatLng>[];

      if (!dMeters.isFinite ||
          !dSeconds.isFinite ||
          dMeters <= 0 ||
          dSeconds <= 0) {
        routeError.value =
            'No encontramos una ruta válida entre el origen y el destino.';
        return;
      }
      distanceKm.value = dMeters / 1000.0;
      durationMin.value = (dSeconds / 60.0).ceil();
      routePoints.assignAll(pts);
      TariffConfiguration configuration;
      try {
        configuration = await _tariffService.getConfiguration();
      } catch (_) {
        if (request == _routeReqId && !isClosed) {
          tariffUnavailable.value = true;
          routeError.value =
              'No pudimos calcular la tarifa estimada. Puedes reintentar o solicitar el viaje sin estimación.';
        }
        return;
      }
      if (request != _routeReqId || isClosed) return;
      tariffConfiguration.value = configuration;
      estimatedFare.value = configuration.estimate(
        distanceKm: distanceKm.value,
        at: _now(),
      );
    } catch (_) {
      if (request == _routeReqId) {
        routeError.value =
            'No pudimos calcular la ruta. Revisa tu conexión y vuelve a intentarlo.';
      }
    } finally {
      if (request == _routeReqId) isCalculating.value = false;
    }
  }

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
        (tariffConfiguration.value != null || tariffUnavailable.value) &&
        (routeError.value.isEmpty || tariffUnavailable.value) &&
        !isCalculating.value &&
        !isResolvingOrigin.value &&
        status.value == TripStatus.idle;
  }

  final Rx<TripStatus> status = TripStatus.idle.obs;
  final Rx<TripModel?> activeTrip = Rx<TripModel?>(null);
  final Rx<LatLng?> driverPosition = Rx<LatLng?>(null);
  final RxBool isCreatingTrip = false.obs;
  bool _createTripInFlight = false;

  Future<void> createTrip() async {
    if (_createTripInFlight || !canCreateTrip) return;

    _createTripInFlight = true;
    isCreatingTrip.value = true;

    try {
      if (tariffUnavailable.value) {
        final routeRequest = _routeReqId;
        final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('¿Solicitar sin tarifa estimada?'),
            content: const Text(
              'No pudimos calcular el costo aproximado. Puedes solicitar el viaje, pero su valor está por confirmar. ¿Deseas continuar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Volver'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Solicitar viaje'),
              ),
            ],
          ),
        );
        if (confirmed != true ||
            isClosed ||
            routeRequest != _routeReqId ||
            !canCreateTrip) {
          return;
        }
      }
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
        telefonoCliente: telefono,
        clienteId: clienteId,
        direccionPartida: originAddress.value,
        ubicacionExactaCliente: exactLocationCtrl.text.trim(),
        latitudPartida: origin.latitude,
        longitudPartida: origin.longitude,
        personaDireccionId: selectedOriginAddressId,
        baseId: selectedOriginBaseId,
        estadoCarrera: 'S',
        unidadId: '0',
        usuarioId: usuarioId,
        direccionDestino: destinationAddress.value,
        latitudDestino: destinationLatLng.value!.latitude,
        longitudDestino: destinationLatLng.value!.longitude,
        distancia: distanceKm.value,
        costo: tariffUnavailable.value ? null : finalFare,
      );

      final created = await _tripService.createTrip(request);
      final carreraId = created.idTravelRequest.toString();

      // Publica la carrera activa antes de consultar al socket: el backend
      // puede responder inmediatamente con una asignación ya existente.
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
        fare: created.hasFare
            ? created.cost.toDouble()
            : tariffUnavailable.value
            ? 0
            : finalFare,
        hasFare: created.hasFare || !tariffUnavailable.value,
        status: TripStatus.searching,
      );

      status.value = TripStatus.searching;
      _tripSocket.listenForTrip(carreraId);
    } catch (e) {
      status.value = TripStatus.failed;
      activeTrip.value = null;
    } finally {
      _createTripInFlight = false;
      isCreatingTrip.value = false;
    }
  }

  /// Prepara la misma carrera recibida por la push y la recupera desde el
  /// servidor. Los datos completos llegan por consultarEstadoCarrera.
  void recoverAssignedTrip(int tripId) {
    if (tripId <= 0) return;
    final id = tripId.toString();
    recoveryError.value = '';
    isRecoveringTrip.value = true;
    _recoveryTimeout?.cancel();
    _recoveryTimeout = Timer(const Duration(seconds: 15), () {
      if (isClosed || !isRecoveringTrip.value) return;
      recoveryError.value =
          'No pudimos consultar el viaje. Vuelve a intentarlo.';
      isRecoveringTrip.value = false;
    });
    if (activeTrip.value?.id == id) {
      _tripSocket.listenForTrip(id);
      return;
    }

    driverPosition.value = null;
    final currentPoint = _gps.currentPosition.value ?? lastCenter;
    activeTrip.value = TripModel(
      id: id,
      origin: currentPoint,
      originName: '',
      destination: currentPoint,
      destinationName: '',
      distanceKm: 0,
      durationMin: 0,
      fare: 0,
      hasDistance: false,
      hasFare: false,
      status: TripStatus.accepted,
    );
    status.value = TripStatus.accepted;
    _tripSocket.listenForTrip(id);
  }

  void _onAssignment(Map<String, dynamic> event) {
    final rawTrip = event['carrera'];
    final trip = rawTrip is Map ? Map<String, dynamic>.from(rawTrip) : event;
    final id = _eventTripId(trip) ?? _eventTripId(event);
    final activeId = activeTrip.value?.id;
    if (id == null || activeId == null || id != activeId) {
      logTripEvent('controlador.ignorado', {
        'motivo': 'Carrera distinta o sin ID activo',
        'id_recibido': id,
      }, activeTripId: activeId);
      return;
    }

    final decodedStatus = tripStatusFromBackend(trip);
    final hasState = [
      'estado_codigo',
      'estado',
      'estadocarrera',
      'estado_carrera',
      'status',
    ].any((key) => trip[key] != null);
    final hasDriver =
        trip['conductor'] != null ||
        trip['conductor_id'] != null ||
        trip['conductorId'] != null;
    final nextStatus =
        decodedStatus ?? (!hasState && hasDriver ? TripStatus.accepted : null);
    if (nextStatus == null) {
      logTripEvent('controlador.ignorado', {
        'motivo': 'Estado no reconocido o sin asignación',
        'payload': trip,
      }, activeTripId: activeId);
      return;
    }
    // Una retransmisión de la asignación no debe reabrir un viaje finalizado.
    final recovered = event['_recovered'] == true;
    if (status.value == TripStatus.completed && !recovered) {
      logTripEvent('controlador.ignorado', {
        'motivo': 'La carrera ya está finalizada',
      }, activeTripId: activeId);
      return;
    }
    const progress = {
      TripStatus.accepted: 1,
      TripStatus.arrived: 2,
      TripStatus.started: 3,
      TripStatus.completed: 4,
      TripStatus.cancelled: 4,
    };
    if (!recovered &&
        (progress[nextStatus] ?? 0) < (progress[status.value] ?? 0)) {
      logTripEvent('controlador.ignorado', {
        'motivo': 'Estado anterior al actual',
        'actual': status.value.name,
        'recibido': nextStatus.name,
      }, activeTripId: activeId);
      return;
    }

    _applyRecoveredTripData(trip);
    final driver = trip['conductor'];
    final position =
        _driverPoint(trip) ??
        (driver is Map
            ? _driverPoint(Map<String, dynamic>.from(driver))
            : null);
    if (position != null) driverPosition.value = position;
    activeTrip.value = activeTrip.value!.copyWith(
      status: nextStatus,
      origin: originLatLng.value,
      originName: originAddress.value,
      destination: destinationLatLng.value,
      destinationName: destinationAddress.value,
      distanceKm: tripNumber(
        trip['distancia'] ?? trip['distancia_km'] ?? trip['distance_km'],
      ),
      fare: tripNumber(trip['costo'] ?? trip['cost']),
      durationMin: durationMin.value > 0 ? durationMin.value : null,
      hasDistance:
          tripNumber(
                trip['distancia'] ??
                    trip['distancia_km'] ??
                    trip['distance_km'],
              ) !=
              null
          ? true
          : null,
      hasFare: tripNumber(trip['costo'] ?? trip['cost']) != null ? true : null,
      assignment: {...?activeTrip.value!.assignment, ...trip},
    );
    logTripEvent('controlador.estadoAplicado', {
      'anterior': status.value.name,
      'nuevo': nextStatus.name,
      'estado_codigo': trip['estado_codigo'],
      'estado': trip['estado'],
      'distancia_km': activeTrip.value!.hasDistance
          ? activeTrip.value!.distanceKm
          : null,
      'costo': activeTrip.value!.hasFare ? activeTrip.value!.fare : null,
      'conductor': activeTrip.value!.assignment?['conductor'],
      'unidad': activeTrip.value!.assignment?['unidad'],
    }, activeTripId: activeId);
    _recoveryTimeout?.cancel();
    recoveryError.value = '';
    isRecoveringTrip.value = false;
    status.value = nextStatus;
    _rememberActiveTrip();
    if (recovered ||
        nextStatus == TripStatus.completed ||
        nextStatus == TripStatus.cancelled) {
      unawaited(_loadTripDetails(activeId));
    }
    if (Get.isRegistered<TripsController>()) {
      unawaited(Get.find<TripsController>().fetchTrips());
    }
  }

  Future<void> _loadTripDetails(String id) async {
    try {
      final details = await _tripService.getTripDetails(id);
      if (isClosed || activeTrip.value?.id != id || details == null) return;
      activeTrip.value = activeTrip.value!.copyWith(
        distanceKm: details.hasDistance ? details.distanceKm.toDouble() : null,
        fare: details.hasFare ? details.cost.toDouble() : null,
        hasDistance: details.hasDistance ? true : null,
        hasFare: details.hasFare ? true : null,
        durationMin: details.estimatedTime.inMinutes > 0
            ? details.estimatedTime.inMinutes
            : null,
        originName: details.departureAddress.isNotEmpty
            ? details.departureAddress
            : null,
        destinationName: details.destinationAddress.isNotEmpty
            ? details.destinationAddress
            : null,
      );
      if (details.departureAddress.isNotEmpty) {
        originAddress.value = details.departureAddress;
      }
      if (details.destinationAddress.isNotEmpty) {
        destinationAddress.value = details.destinationAddress;
      }
      if (details.hasDistance) distanceKm.value = details.distanceKm.toDouble();
      if (details.hasFare) estimatedFare.value = details.cost.toDouble();
      _rememberActiveTrip();
    } catch (error) {
      logTripEvent('historial.detallesNoDisponibles', {
        'carrera_id': id,
        'error': error.toString(),
      });
    }
  }

  void _applyRecoveredTripData(Map<String, dynamic> trip) {
    final origin =
        _readPoint(
          trip['coordenadaspartida'] ??
              trip['coordenadas_origen'] ??
              trip['departure_coords'],
        ) ??
        _readPoint({
          'lat': trip['latitudpartida'] ?? trip['latitud_partida'],
          'long':
              trip['longitudpartida'] ??
              trip['longitud_partida'] ??
              trip['longitudorigen'],
        });
    final destination =
        _readPoint(
          trip['coordenadasdestino'] ??
              trip['coordenadas_destino'] ??
              trip['destination_coords'],
        ) ??
        _readPoint({
          'lat': trip['latituddestino'] ?? trip['latitud_destino'],
          'long': trip['longituddestino'] ?? trip['longitud_destino'],
        });

    if (origin != null) {
      originLatLng.value = origin;
      lastCenter = origin;
    }
    if (destination != null) destinationLatLng.value = destination;

    final originText = _firstText([
      trip['direccionpartida'],
      trip['direccion_origen'],
      trip['departure_address'],
    ]);
    final destinationText = _firstText([
      trip['direcciondestino'],
      trip['direccion_destino'],
      trip['destination_address'],
    ]);
    if (originText.isNotEmpty) originAddress.value = originText;
    if (destinationText.isNotEmpty) destinationAddress.value = destinationText;

    final distance = tripNumber(
      trip['distancia'] ?? trip['distancia_km'] ?? trip['distance_km'],
    );
    if (distance != null) distanceKm.value = distance;

    final duration = _asDouble(
      trip['duracion_min'] ?? trip['duration_min'] ?? trip['tiempo_minutos'],
    );
    if (duration != null && duration > 0) durationMin.value = duration.round();

    final fare = tripNumber(trip['costo'] ?? trip['cost']);
    if (fare != null) estimatedFare.value = fare;
  }

  LatLng? _readPoint(dynamic raw) {
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map || decoded is List) return _readPoint(decoded);
      } catch (_) {
        final parts = raw.split(',');
        if (parts.length >= 2) {
          final lat = _asDouble(parts[0]);
          final lng = _asDouble(parts[1]);
          if (lat != null && lng != null) return LatLng(lat, lng);
        }
      }
      return null;
    }
    if (raw is List && raw.length >= 2) {
      final lat = _asDouble(raw[0]);
      final lng = _asDouble(raw[1]);
      if (lat != null && lng != null) return LatLng(lat, lng);
      return null;
    }
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final lat = _asDouble(map['lat'] ?? map['latitude'] ?? map['latitud']);
    final lng = _asDouble(
      map['long'] ??
          map['lng'] ??
          map['lon'] ??
          map['longitude'] ??
          map['longitud'],
    );
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  String _firstText(Iterable<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
    }
    return '';
  }

  void _onLocation(Map<String, dynamic> event) {
    final id = _eventTripId(event);
    if (id == null || id != activeTrip.value?.id) return;
    final position = _driverPoint(event);
    if (position != null) {
      driverPosition.value = position;
      _rememberActiveTrip();
    }
  }

  LatLng? _driverPoint(Map<String, dynamic> data) {
    final point =
        _readPoint(
          data['ubicacion'] ??
              data['coordenadas'] ??
              data['location'] ??
              data['posicion'],
        ) ??
        _readPoint(data);
    if (point == null ||
        !point.latitude.isFinite ||
        !point.longitude.isFinite ||
        point.latitude.abs() > 90 ||
        point.longitude.abs() > 180) {
      return null;
    }
    return point;
  }

  void _handleStatusChange(TripStatus nextStatus) {
    if (nextStatus == TripStatus.completed ||
        nextStatus == TripStatus.cancelled) {
      ActiveTripSession.instance.clear();
    }
    if (nextStatus == TripStatus.searching && !_searchDialogVisible) {
      _searchDialogVisible = true;
      Get.dialog<void>(
        SearchingDriverDialog(onCancel: cancelTrip),
        barrierDismissible: false,
      ).whenComplete(() => _searchDialogVisible = false);
      return;
    }

    if (nextStatus != TripStatus.searching && _searchDialogVisible) {
      if (Get.isDialogOpen == true) Get.back<void>();
      _searchDialogVisible = false;
    }
  }

  String? _eventTripId(Map<String, dynamic> event) {
    final value =
        event['carrera_id'] ??
        event['carreraId'] ??
        event['id_travel_request'] ??
        event['idcarrera'] ??
        event['id_carrera'] ??
        event['id'];
    return value?.toString();
  }

  void cancelTrip() {
    status.value = TripStatus.cancelled;
    activeTrip.value = null;
    resetTrip();
    status.value = TripStatus.idle;
  }

  void resetTrip() {
    _routeReqId++;
    routeError.value = '';
    isCalculating.value = false;
    _recoveryTimeout?.cancel();
    isRecoveringTrip.value = false;
    recoveryError.value = '';
    ActiveTripSession.instance.clear();
    driverPosition.value = null;
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

  void _rememberActiveTrip() {
    final trip = activeTrip.value;
    final currentStatus = status.value;
    if (trip == null ||
        (currentStatus != TripStatus.accepted &&
            currentStatus != TripStatus.arrived &&
            currentStatus != TripStatus.started)) {
      return;
    }
    final session = ActiveTripSession.instance;
    session.driverPosition = driverPosition.value;
    session.trip.value = TripModel(
      id: trip.id,
      origin: originLatLng.value ?? trip.origin,
      originName: originAddress.value,
      destination: destinationLatLng.value ?? trip.destination,
      destinationName: destinationAddress.value,
      distanceKm: trip.distanceKm,
      durationMin: trip.durationMin,
      fare: trip.fare,
      hasDistance: trip.hasDistance,
      hasFare: trip.hasFare,
      status: currentStatus,
      assignment: trip.assignment,
    );
  }

  @override
  void onClose() {
    _rememberActiveTrip();
    _assignmentSubscription?.cancel();
    _locationSubscription?.cancel();
    _socketErrorSubscription?.cancel();
    _stateSubscription?.cancel();
    _recoveryTimeout?.cancel();
    _statusWorker?.dispose();
    _tripSocket.dispose();
    _gpsWorker?.dispose();
    _debounce?.cancel();
    searchCtrl.dispose();
    exactLocationCtrl.dispose();
    _geocoder.dispose();
    super.onClose();
  }
}
