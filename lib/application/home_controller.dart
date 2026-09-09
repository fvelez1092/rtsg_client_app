import 'package:app_rtsg_client/application/home_content_controller.dart';
import 'package:app_rtsg_client/application/trips_controller.dart';
import 'package:app_rtsg_client/data/models/trips/trip_model.dart';
import 'package:app_rtsg_client/data/models/partnert_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  HomeController(this._contentController, this._tripsController);

  final HomeContentController _contentController;
  final TripsController _tripsController;

  final PageController advertisementsPageController = PageController(
    viewportFraction: 0.91,
  );

  final RxInt selectedAdvertisementIndex = 0.obs;

  RxBool get isLoading => _contentController.isLoading;
  RxBool get hasError => _contentController.hasError;
  RxString get errorMessage => _contentController.errorMessage;

  RxList<PartnerAdModel> get advertisements => _contentController.publicidades;
  RxList<PartnerModel> get partners => _contentController.partners;
  RxList<Trip> get trips => _tripsController.trips;
  RxBool get tripsLoading => _tripsController.loading;
  RxString get tripsError => _tripsController.error;

  Trip? get latestTrip {
    if (trips.isEmpty) return null;

    return trips.reduce(
      (current, next) =>
          next.requestedDate.isAfter(current.requestedDate) ? next : current,
    );
  }

  PartnerModel? partnerForAdvertisement(PartnerAdModel advertisement) {
    final partnerId = advertisement.partnerId;
    final partnerName = advertisement.partnerName.trim().toLowerCase();

    for (final partner in partners) {
      if (partnerId != null && partner.id == partnerId) return partner;
      if (partnerName.isNotEmpty &&
          partner.name.trim().toLowerCase() == partnerName) {
        return partner;
      }
    }
    return null;
  }

  Future<void> loadHome() async {
    await Future.wait([
      _contentController.loadContent(),
      _tripsController.fetchTrips(),
    ]);
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
