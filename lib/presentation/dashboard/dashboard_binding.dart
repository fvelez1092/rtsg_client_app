import 'package:app_rtsg_client/application/dashboard_controller.dart';
import 'package:app_rtsg_client/application/home_controller.dart';
import 'package:app_rtsg_client/data/services/home_services.dart';
import 'package:get/get.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);

    Get.lazyPut<HomeService>(() => HomeService(), fenix: true);

    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<HomeService>()),
      fenix: true,
    );

    // Después se registran los demás:
    // Get.lazyPut<ActivityController>(() => ActivityController());
    // Get.lazyPut<WalletController>(() => WalletController());
    // Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
