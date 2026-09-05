import 'package:app_rtsg_client/data/models/partnert_model.dart';
import 'package:app_rtsg_client/data/services/home_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  HomeController(this._homeService);

  final HomeService _homeService;

  final PageController advertisementsPageController = PageController(
    viewportFraction: 0.91,
  );

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;

  final RxList<PartnerAdModel> advertisements = <PartnerAdModel>[].obs;
  final RxList<PartnerModel> partners = <PartnerModel>[].obs;

  final RxInt selectedAdvertisementIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadHome();
  }

  Future<void> loadHome() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final results = await Future.wait([
        _homeService.getPartnerAds(),
        _homeService.getPartners(),
      ]);

      advertisements.assignAll(results[0] as List<PartnerAdModel>);
      partners.assignAll(results[1] as List<PartnerModel>);
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void changeAdvertisement(int index) {
    selectedAdvertisementIndex.value = index;
  }

  @override
  void onClose() {
    advertisementsPageController.dispose();
    super.onClose();
  }
}
