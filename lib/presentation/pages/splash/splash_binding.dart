import 'package:app_rtsg_client/application/splash_controller.dart';
import 'package:get/get.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // ✅ Create immediately so onInit/onReady will run for sure
    Get.put<SplashController>(SplashController(), permanent: true);
  }
}
