import 'package:get/get.dart';
import 'package:app_rtsg_client/data/services/user_service.dart';
import 'package:app_rtsg_client/global_memory.dart';
import 'package:app_rtsg_client/routes/rtsg_routes.dart';

class SplashController extends GetxController {
  SplashController(this._userService);

  final UserService _userService;
  final GlobalMemory _memory = GlobalMemory.to;

  @override
  void onReady() {
    super.onReady();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(milliseconds: 350));

    final token = await _memory.getToken();
    final hasToken = token != null && token.trim().isNotEmpty;

    if (!hasToken) {
      Get.offAllNamed(AppRoutes.LOGIN);
      return;
    }

    try {
      final user = await _userService.getUserByToken();
      await _memory.setUser(user);
      Get.offAllNamed(AppRoutes.DASHBOARD);
    } catch (_) {
      await _memory.logout();
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}
