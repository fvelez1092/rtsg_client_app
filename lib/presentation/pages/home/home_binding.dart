import 'package:app_rtsg_client/application/home_content_controller.dart';
import 'package:app_rtsg_client/application/home_controller.dart';
import 'package:app_rtsg_client/application/trips_controller.dart';
import 'package:app_rtsg_client/data/services/partners_service.dart';
import 'package:app_rtsg_client/data/services/publicidad_service.dart';
import 'package:app_rtsg_client/data/services/trip_service.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartnersService>(() => PartnersService(), fenix: true);
    Get.lazyPut<PublicidadService>(() => PublicidadService(), fenix: true);
    Get.lazyPut<TripService>(() => TripService(), fenix: true);
    Get.lazyPut<TripsController>(
      () => TripsController(Get.find<TripService>()),
      fenix: true,
    );

    Get.lazyPut<HomeContentController>(
      () => HomeContentController(
        partnersService: Get.find<PartnersService>(),
        publicidadService: Get.find<PublicidadService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<HomeController>(
      () => HomeController(
        Get.find<HomeContentController>(),
        Get.find<TripsController>(),
      ),
      fenix: true,
    );
  }
}
