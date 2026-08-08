import 'package:get/get.dart';

class DashboardController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  void changePage(int index) {
    if (selectedIndex.value == index) return;

    selectedIndex.value = index;
  }
}
