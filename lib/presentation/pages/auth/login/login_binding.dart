import 'package:app_rtsg_client/application/auth_controller.dart';
import 'package:app_rtsg_client/data/services/auth_service.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService());
    Get.lazyPut<AuthController>(() => AuthController(authService: Get.find()));
  }
}
