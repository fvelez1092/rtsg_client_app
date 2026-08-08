import 'package:app_rtsg_client/application/home_controller.dart';
import 'package:app_rtsg_client/data/services/home_services.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeService>(() => HomeService(), fenix: true);

    Get.lazyPut<HomeController>(() => HomeController(Get.find<HomeService>()));
  }
}
