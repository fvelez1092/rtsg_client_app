import 'package:app_rtsg_client/presentation/pages/home/components/home_trip_panel.dart';
import 'package:app_rtsg_client/presentation/widgets/app_drawer.dart';
import 'package:app_rtsg_client/presentation/widgets/drawer_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_rtsg_client/application/home_controller.dart';
import 'package:app_rtsg_client/application/trip_controller.dart';
import 'package:app_rtsg_client/presentation/widgets/map_widget.dart';
import 'package:app_rtsg_client/core/theme/app_colors.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final trip = Get.find<TripController>();

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  Obx(() {
                    final origin = trip.originLatLng.value;
                    final dest = trip.destinationLatLng.value;

                    final showMarkers =
                        origin != null &&
                        dest != null &&
                        trip.routePoints.length >= 2;

                    return MapPicker(
                      initialCenter: controller.lastCenter,
                      initialZoom: 16,
                      centerLabel: controller.centerLabel.value,
                      onChanged: (center, zoom, {required isFinal}) {
                        controller.onMapChanged(center, zoom, isFinal: isFinal);
                      },

                      // ✅ Ruta
                      routePoints: trip.routePoints,
                      showRoute: trip.routePoints.length >= 2,

                      // ✅ Marcadores inicio/fin
                      showRouteMarkers: showMarkers,
                      routeStart: showMarkers ? origin : null,
                      routeEnd: showMarkers ? dest : null,

                      // ✅ Overlay cargando ruta
                      showLoadingOverlay: trip.isCalculating.value,
                      loadingText: 'Calculando ruta…',
                    );
                  }),
                  const Positioned(top: 12, left: 12, child: AppDrawerButton()),
                ],
              ),
            ),
            const Expanded(flex: 4, child: HomeTripPanel()),
          ],
        ),
      ),
    );
  }
}
