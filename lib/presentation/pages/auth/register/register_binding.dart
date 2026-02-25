import 'package:get/get.dart';

import 'package:app_rtsg_client/application/register_controller.dart';
import 'package:app_rtsg_client/data/services/auth_service.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService());
    Get.lazyPut<RegisterController>(
      () => RegisterController(authService: Get.find()),
    );
  }
}
