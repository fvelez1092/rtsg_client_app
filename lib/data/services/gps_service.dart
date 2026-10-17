import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

enum LocationAccess {
  unknown,
  available,
  serviceDisabled,
  denied,
  deniedForever,
  unavailable,
}

class GpsService extends GetxService with WidgetsBindingObserver {
  GpsService({GeolocatorPlatform? platform})
    : _platform = platform ?? GeolocatorPlatform.instance;
  final GeolocatorPlatform _platform;
  final Rx<LatLng?> currentPosition = Rx<LatLng?>(null);
  final RxBool isLoading = false.obs;
  final Rx<LocationAccess> access = LocationAccess.unknown.obs;
  final RxString error = ''.obs;
  Future<void>? _pending;
  StreamSubscription<ServiceStatus>? _serviceSubscription;
  StreamSubscription<Position>? _positionSubscription;
  bool _observing = false;

  bool get hasUsableLocation =>
      currentPosition.value != null && access.value == LocationAccess.available;

  Future<GpsService> init() async {
    _log('init: iniciar verificación GPS');
    if (!_observing) {
      WidgetsBinding.instance.addObserver(this);
      _observing = true;
      try {
        _serviceSubscription = _platform.getServiceStatusStream().listen(
          (status) {
            if (status == ServiceStatus.disabled) {
              _unavailable(
                LocationAccess.serviceDisabled,
                'Activa la ubicación del teléfono.',
              );
            } else {
              unawaited(getCurrentLocation(requestPermission: false));
            }
          },
          onError: (Object error) => debugPrint('[RTSG][GPS] Servicio: $error'),
        );
      } catch (error) {
        debugPrint('[RTSG][GPS] Monitor no disponible: $error');
      }
    }
    // La app puede abrirse aunque el GPS tarde o el usuario no conceda permiso.
    unawaited(getCurrentLocation());
    return this;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(getCurrentLocation(requestPermission: false));
    }
  }

  Future<void> getCurrentLocation({bool requestPermission = true}) {
    _log(
      'solicitud ubicación requestPermission=$requestPermission '
      'pending=${_pending != null} access=${access.value}',
    );
    return _pending ??= _resolve(
      requestPermission,
    ).whenComplete(() => _pending = null);
  }

  Future<void> _resolve(bool requestPermission) async {
    isLoading.value = true;
    error.value = '';
    try {
      final serviceEnabled = await _platform.isLocationServiceEnabled();
      _log('servicio GPS habilitado=$serviceEnabled');
      if (!serviceEnabled) {
        _unavailable(
          LocationAccess.serviceDisabled,
          'Activa la ubicación del teléfono.',
        );
        return;
      }
      var permission = await _platform.checkPermission();
      _log('permiso inicial=$permission');
      if (permission == LocationPermission.denied && requestPermission) {
        permission = await _platform.requestPermission();
        _log('permiso después de solicitud=$permission');
      }
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        _unavailable(
          permission == LocationPermission.deniedForever
              ? LocationAccess.deniedForever
              : LocationAccess.denied,
          'Comparte tu ubicación desde los permisos de la aplicación.',
        );
        return;
      }
      Position position;
      try {
        position = await _platform.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 12),
          ),
        );
      } catch (_) {
        if (defaultTargetPlatform != TargetPlatform.android) rethrow;
        debugPrint(
          '[RTSG][GPS] Reintentando con el proveedor de ubicación de Android',
        );
        position = await _platform.getCurrentPosition(
          locationSettings: AndroidSettings(
            accuracy: LocationAccuracy.high,
            forceLocationManager: true,
            timeLimit: const Duration(seconds: 10),
          ),
        );
      }
      if (!await _platform.isLocationServiceEnabled()) {
        _unavailable(
          LocationAccess.serviceDisabled,
          'Activa la ubicación del teléfono.',
        );
        return;
      }
      final permissionNow = await _platform.checkPermission();
      if (permissionNow != LocationPermission.whileInUse &&
          permissionNow != LocationPermission.always) {
        _unavailable(
          permissionNow == LocationPermission.deniedForever
              ? LocationAccess.deniedForever
              : LocationAccess.denied,
          'Comparte tu ubicación desde los ajustes.',
        );
        return;
      }
      currentPosition.value = LatLng(position.latitude, position.longitude);
      access.value = LocationAccess.available;
      _log(
        'ubicación disponible lat=${position.latitude} '
        'lng=${position.longitude} precisión=${position.accuracy}m',
      );
    } catch (exception) {
      _unavailable(
        LocationAccess.unavailable,
        'No pudimos obtener tu ubicación. Activa el GPS y vuelve a intentarlo.',
      );
      _log('falló la lectura de ubicación: $exception');
    } finally {
      isLoading.value = false;
    }
  }

  void _unavailable(LocationAccess state, String message) {
    currentPosition.value = null;
    access.value = state;
    error.value = message;
    _log('ubicación no disponible estado=$state mensaje=$message');
    unawaited(_positionSubscription?.cancel());
    _positionSubscription = null;
  }

  Future<bool> openLocationConfiguration() async {
    _log('abrir configuración para estado=${access.value}');
    if (access.value == LocationAccess.denied ||
        access.value == LocationAccess.deniedForever) {
      return _platform.openAppSettings();
    }
    return _platform.openLocationSettings();
  }

  void listenLocation() {
    if (!hasUsableLocation || _positionSubscription != null) return;
    _positionSubscription = _platform.getPositionStream().listen(
      (pos) {
        currentPosition.value = LatLng(pos.latitude, pos.longitude);
        access.value = LocationAccess.available;
      },
      onError: (Object exception) {
        _unavailable(
          LocationAccess.unavailable,
          'No pudimos actualizar tu ubicación.',
        );
      },
    );
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[RTSG][GPS] $message');
  }

  @override
  void onClose() {
    if (_observing) WidgetsBinding.instance.removeObserver(this);
    _serviceSubscription?.cancel();
    _positionSubscription?.cancel();
    super.onClose();
  }
}
