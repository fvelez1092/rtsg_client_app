import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class GpsService extends GetxService {
  // ubicación actual reactiva
  final Rx<LatLng?> currentPosition = Rx<LatLng?>(null);

  // estado de carga
  final RxBool isLoading = false.obs;

  Future<GpsService> init() async {
    await _ensurePermission();
    await getCurrentLocation();
    return this;
  }

  Future<void> _ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // aquí puedes lanzar una excepción o manejarlo como quieras
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      currentPosition.value = LatLng(pos.latitude, pos.longitude);
    } catch (e) {
      // podrías loguear
    } finally {
      isLoading.value = false;
    }
  }

  /// Si luego quieres escuchar cambios:
  void listenLocation() {
    Geolocator.getPositionStream().listen((pos) {
      currentPosition.value = LatLng(pos.latitude, pos.longitude);
    });
  }
}
