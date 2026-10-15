import 'dart:async';
import 'package:app_rtsg_client/application/trips_controller.dart';
import 'package:app_rtsg_client/routes/rtsg_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
    if (index == 1 && Get.isRegistered<TripsController>()) {
      unawaited(Get.find<TripsController>().fetchTrips());
    }
    if (index < 0 || index > 3 || selectedIndex.value == index) return;
    selectedIndex.value = index;
    showNavigation();
  }

  bool handleTabScroll(ScrollNotification notification) {
    if (isClosed || notification.depth != 0) return false;
    if (notification.metrics.pixels <= 6) {
      showNavigation();
      return false;
    }
    final direction = notification is ScrollUpdateNotification
        ? (notification.scrollDelta ?? 0) > 0
              ? ScrollDirection.reverse
              : (notification.scrollDelta ?? 0) < 0
              ? ScrollDirection.forward
              : ScrollDirection.idle
        : notification is UserScrollNotification
        ? notification.direction
        : ScrollDirection.idle;
    switch (direction) {
      case ScrollDirection.reverse:
        if (notification.metrics.extentBefore > 18) hideNavigation();
        break;
      case ScrollDirection.forward:
        showNavigation();
        break;
      case ScrollDirection.idle:
        break;
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
