import 'package:app_rtsg_client/routes/rtsg_routes.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    selectedIndex.value = _indexFromRoute(Get.currentRoute);

    final args = Get.arguments;
    if (args is Map && args['tab'] is int) {
      final tab = args['tab'] as int;
      if (tab >= 0 && tab <= 3) {
        selectedIndex.value = tab;
      }
    }
  }

  void changePage(int index) {
    if (index < 0 || index > 3 || selectedIndex.value == index) return;
    selectedIndex.value = index;
  }

  int _indexFromRoute(String route) {
    return switch (route) {
      AppRoutes.ACTIVITY => 1,
      AppRoutes.WALLET => 2,
      AppRoutes.ACCOUNT => 3,
      _ => 0,
    };
  }
}
