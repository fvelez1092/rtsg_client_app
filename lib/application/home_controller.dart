import 'package:app_rtsg_client/application/home_content_controller.dart';
import 'package:app_rtsg_client/data/models/partnert_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  HomeController(this._contentController);

  final HomeContentController _contentController;

  final PageController advertisementsPageController = PageController(
    viewportFraction: 0.91,
  );

  final RxInt selectedAdvertisementIndex = 0.obs;

  RxBool get isLoading => _contentController.isLoading;
  RxBool get hasError => _contentController.hasError;
  RxString get errorMessage => _contentController.errorMessage;

  RxList<PartnerAdModel> get advertisements => _contentController.publicidades;
  RxList<PartnerModel> get partners => _contentController.partners;

  Future<void> loadHome() => _contentController.loadContent();

  void changeAdvertisement(int index) {
    selectedAdvertisementIndex.value = index;
  }

  @override
  void onClose() {
    advertisementsPageController.dispose();
    super.onClose();
  }
}
