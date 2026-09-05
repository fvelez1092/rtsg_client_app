import 'package:app_rtsg_client/routes/rtsg_routes.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxBool isNavigationVisible = true.obs;

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
    showNavigation();
  }

  bool handleScrollNotification(ScrollNotification notification) {
    // Solo reaccionamos al scroll vertical de las páginas. Los carruseles
    // horizontales del Home no deben modificar la navegación principal.
    if (notification.metrics.axis != Axis.vertical) return false;

    if (notification.metrics.pixels <= 4) {
      showNavigation();
      return false;
    }

    if (notification is UserScrollNotification) {
      switch (notification.direction) {
        case ScrollDirection.reverse:
          if (notification.metrics.extentBefore > 20) {
            hideNavigation();
          }
          break;
        case ScrollDirection.forward:
          showNavigation();
          break;
        case ScrollDirection.idle:
          break;
      }
    }

    return false;
  }

  void showNavigation() {
    if (!isNavigationVisible.value) {
      isNavigationVisible.value = true;
    }
  }

  void hideNavigation() {
    if (isNavigationVisible.value) {
      isNavigationVisible.value = false;
    }
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
