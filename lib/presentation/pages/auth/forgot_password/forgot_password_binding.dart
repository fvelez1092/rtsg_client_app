import 'package:get/get.dart';
import 'package:app_rtsg_client/application/forgot_password_controller.dart';
import 'package:app_rtsg_client/data/services/auth_service.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService());
    Get.lazyPut<ForgotPasswordController>(
      () => ForgotPasswordController(authService: Get.find()),
    );
  }
}
