import 'package:app_rtsg_client/data/services/gps_service.dart';
import 'package:app_rtsg_client/data/services/mapbox_service.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:app_rtsg_client/application/trip_controller.dart';

class HomeController extends GetxController {
  final MapboxGeocoder _geocoder;
  final GpsService _gpsService = Get.find<GpsService>();
  final TripController _tripController = Get.find<TripController>();

  HomeController({MapboxGeocoder? geocoder})
    : _geocoder = geocoder ?? MapboxGeocoder();

  final RxString centerLabel = 'Buscando ubicación…'.obs;

  LatLng lastCenter = LatLng(-0.18065, -78.46783);
  int _reqId = 0;

  @override
  void onInit() {
    super.onInit();

    final gpsPos = _gpsService.currentPosition.value;
    if (gpsPos != null) {
      lastCenter = gpsPos;
      _resolveAddress(gpsPos);
    }

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

  // ✅ Para “Cambiar origen” por búsqueda o por seleccionar en mapa
  void setOriginFromExternal({required LatLng point, required String address}) {
    lastCenter = point;
    centerLabel.value = address;

    _tripController.setOrigin(address: address, point: point);
    update(); // por si usas GetBuilder en algún lado
  }

  Future<void> _resolveAddress(LatLng center) async {
    final currentReq = ++_reqId;

    final placeName = await _geocoder.reverse(
      lat: center.latitude,
      lon: center.longitude,
    );

    if (currentReq != _reqId) return;

    final resolved = placeName ?? 'Dirección no disponible';
    centerLabel.value = resolved;

    // sincroniza origen en trip
    _tripController.setOrigin(address: resolved, point: center);
  }

  @override
  void onClose() {
    _geocoder.dispose();
    super.onClose();
  }
}
