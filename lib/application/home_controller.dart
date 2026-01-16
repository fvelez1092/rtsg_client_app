import 'package:app_rtsg_client/data/services/gps_service.dart';
import 'package:app_rtsg_client/data/services/mapbox_service.dart';

import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class HomeController extends GetxController {
  final MapboxGeocoder _geocoder;
  final GpsService _gpsService = Get.find<GpsService>();

  HomeController({MapboxGeocoder? geocoder})
    : _geocoder = geocoder ?? MapboxGeocoder();

  final RxString centerLabel = 'Buscando ubicación…'.obs;

  /// Centro actual del mapa
  LatLng lastCenter = LatLng(-0.18065, -78.46783); // fallback

  int _reqId = 0;

  @override
  void onInit() {
    super.onInit();

    // Si el GPS ya tiene posición, úsala
    final gpsPos = _gpsService.currentPosition.value;
    if (gpsPos != null) {
      lastCenter = gpsPos;
      _resolveAddress(gpsPos);
    }

    // Escucha cambios del GPS (por si tarda)
    ever<LatLng?>(_gpsService.currentPosition, (pos) {
      if (pos != null) {
        lastCenter = pos;
        _resolveAddress(pos);
      }
    });
  }

  void onMapChanged(LatLng center, double zoom, {required bool isFinal}) {
    lastCenter = center;

    if (!isFinal) {
      centerLabel.value = 'Buscando dirección…';
      return;
    }

    _resolveAddress(center);
  }

  Future<void> _resolveAddress(LatLng center) async {
    final currentReq = ++_reqId;

    final placeName = await _geocoder.reverse(
      lat: center.latitude,
      lon: center.longitude,
    );

    if (currentReq != _reqId) return;

    centerLabel.value = placeName ?? 'Dirección no disponible';
  }

  @override
  void onClose() {
    _geocoder.dispose();
    super.onClose();
  }
}
