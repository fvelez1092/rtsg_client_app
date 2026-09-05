import 'package:app_rtsg_client/routes/rtsg_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxBool isNavigationVisible = true.obs;

  late final List<ScrollController> tabScrollControllers;

  @override
  void onInit() {
    super.onInit();

    tabScrollControllers = List<ScrollController>.generate(4, (index) {
      final scrollController = ScrollController();
      scrollController.addListener(
        () => _handleTabScroll(scrollController),
      );
      return scrollController;
    });

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

  void _handleTabScroll(ScrollController scrollController) {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;

    // En el inicio de la página la navegación siempre debe estar visible.
    if (position.pixels <= 6) {
      showNavigation();
      return;
    }

    switch (position.userScrollDirection) {
      case ScrollDirection.reverse:
        // reverse = el contenido avanza hacia abajo.
        if (position.extentBefore > 18) {
          hideNavigation();
        }
        break;
      case ScrollDirection.forward:
        // forward = el usuario vuelve hacia la parte superior.
        showNavigation();
        break;
      case ScrollDirection.idle:
        break;
    }
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

  @override
  void onClose() {
    for (final scrollController in tabScrollControllers) {
      scrollController.dispose();
    }
    super.onClose();
  }
}
