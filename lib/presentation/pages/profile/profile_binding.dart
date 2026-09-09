import 'package:app_rtsg_client/application/profile_controller.dart';
import 'package:app_rtsg_client/data/services/saved_address_service.dart';
import 'package:get/get.dart';

class ProfileBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SavedAddressService>(
      () => SavedAddressService(),
      fenix: true,
    );
    Get.lazyPut<ProfileController>(
      () => ProfileController(Get.find<SavedAddressService>()),
    );
  }
}
