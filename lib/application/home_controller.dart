import 'package:app_rtsg_client/data/services/mapbox_service.dart';

import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class HomeController extends GetxController {
  final MapboxGeocoder _geocoder;

  HomeController({MapboxGeocoder? geocoder})
    : _geocoder = geocoder ?? MapboxGeocoder();

  final RxString centerLabel = 'Selecciona tu ubicación'.obs;

  LatLng lastCenter = LatLng(-0.18065, -78.46783);

  int _reqId = 0;

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
