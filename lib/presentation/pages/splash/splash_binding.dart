import 'package:app_rtsg_client/application/splash_controller.dart';
import 'package:app_rtsg_client/data/services/user_service.dart';
import 'package:get/get.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserService>(() => UserService(), fenix: true);
    Get.put<SplashController>(
      SplashController(Get.find<UserService>()),
      permanent: true,
    );
  }
}
