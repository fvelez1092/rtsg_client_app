import 'package:app_rtsg_client/application/trip_controller.dart';
import 'package:app_rtsg_client/data/services/trip_service.dart';
import 'package:get/get.dart';

class TripBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TripService>(() => TripService());
    Get.lazyPut<TripController>(() => TripController());
  }
}
