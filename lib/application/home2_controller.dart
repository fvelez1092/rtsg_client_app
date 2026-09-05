import 'package:app_rtsg_client/data/services/gps_service.dart';
import 'package:app_rtsg_client/data/services/mapbox_service.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:app_rtsg_client/application/trip_controller.dart';

class Home2Controller extends GetxController {
  final MapboxGeocoder _geocoder;
  final GpsService _gpsService = Get.find<GpsService>();
  final TripController _tripController = Get.find<TripController>();

  Home2Controller({MapboxGeocoder? geocoder})
    : _geocoder = geocoder ?? MapboxGeocoder();

  final RxString centerLabel = 'Buscando ubicación…'.obs;
  final RxBool isResolvingOrigin = false.obs;

  LatLng lastCenter = const LatLng(-0.18065, -78.46783);
  int _reqId = 0;
  bool _originWasSelectedManually = false;

  @override
  void onInit() {
    super.onInit();

    final gpsPos = _gpsService.currentPosition.value;
    if (gpsPos != null) {
      lastCenter = gpsPos;
      _resolveAddress(gpsPos);
    }

    ever<LatLng?>(_gpsService.currentPosition, (pos) {
      if (pos != null &&
          !_originWasSelectedManually &&
          _tripController.destinationLatLng.value == null) {
        lastCenter = pos;
        _resolveAddress(pos);
      }
    });
  }

  void onMapChanged(LatLng center, double zoom, {required bool isFinal}) {
    if (_tripController.destinationLatLng.value != null) return;

    lastCenter = center;
    _originWasSelectedManually = true;

    if (!isFinal) {
      centerLabel.value = 'Buscando dirección…';
      isResolvingOrigin.value = true;
      return;
    }

    _resolveAddress(center);
  }

  void setOriginFromExternal({required LatLng point, required String address}) {
    _originWasSelectedManually = true;
    lastCenter = point;
    centerLabel.value = address;
    isResolvingOrigin.value = false;
    _tripController.setOrigin(address: address, point: point);
    update();
  }

  Future<bool> useCurrentLocation() async {
    var position = _gpsService.currentPosition.value;

    if (position == null) {
      await _gpsService.getCurrentLocation();
      position = _gpsService.currentPosition.value;
    }

    if (position == null) return false;

    _originWasSelectedManually = false;
    lastCenter = position;
    await _resolveAddress(position);
    return true;
  }

  Future<void> _resolveAddress(LatLng center) async {
    final currentReq = ++_reqId;
    isResolvingOrigin.value = true;

    final placeName = await _geocoder.reverse(
      lat: center.latitude,
      lon: center.longitude,
    );

    if (currentReq != _reqId) return;

    final resolved = placeName ?? 'Dirección no disponible';
    centerLabel.value = resolved;
    isResolvingOrigin.value = false;
    _tripController.setOrigin(address: resolved, point: center);
  }

  @override
  void onClose() {
    _geocoder.dispose();
    super.onClose();
  }
}
