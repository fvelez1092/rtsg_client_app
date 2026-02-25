import 'package:get/get.dart';
import 'package:app_rtsg_client/global_memory.dart';
import 'package:app_rtsg_client/routes/rtsg_routes.dart';

class SplashController extends GetxController {
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

    if (hasToken) {
      await _memory.getUser(forceRefresh: true);
      Get.offAllNamed(AppRoutes.HOME); // o tu ruta real
    } else {
      Get.offAllNamed(AppRoutes.LOGIN); // o tu ruta real
    }
  }
}
