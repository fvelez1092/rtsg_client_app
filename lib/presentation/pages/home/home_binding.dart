import 'package:app_rtsg_client/application/home_controller.dart';
import 'package:app_rtsg_client/application/trip_controller.dart';
import 'package:app_rtsg_client/data/services/trip_simulator_service.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TripSimulatorService>(() => TripSimulatorService());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<TripController>(() => TripController());
  }
}
