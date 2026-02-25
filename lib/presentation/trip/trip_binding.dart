import 'package:app_rtsg_client/application/trips_controller.dart';
import 'package:app_rtsg_client/data/services/trip_service.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class TripBinding extends Bindings {
  final LatLng initial;
  final String mapTag;
  TripBinding({required this.initial, this.mapTag = 'home-picker'});

  @override
  void dependencies() {
    Get.lazyPut<TripService>(() => TripService());
    Get.put<TripsController>(TripsController(Get.find<TripService>()));
    // Get.put<TripBookingController>(
    //   TripBookingController(Get.find<TripService>()),
    // );
  }
}
