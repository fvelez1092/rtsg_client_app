import 'package:app_rtsg_client/application/home_controller.dart';
import 'package:app_rtsg_client/presentation/pages/home/components/home_app_drawer.dart';
import 'package:app_rtsg_client/presentation/pages/home/components/home_drawer_button.dart';
import 'package:app_rtsg_client/presentation/pages/home/components/home_trip_panel.dart';
import 'package:app_rtsg_client/presentation/widgets/map_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: const HomeAppDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            // 60% MAPA
            Column(
              children: [
                Expanded(
                  flex: 6,
                  child: Stack(
                    children: [
                      Obx(() {
                        return MapPicker(
                          initialCenter: controller.lastCenter,
                          initialZoom: 13.0,
                          centerLabel: controller.centerLabel.value,
                          onChanged: (center, zoom, {required isFinal}) {
                            controller.onMapChanged(
                              center,
                              zoom,
                              isFinal: isFinal,
                            );
                          },
                        );
                      }),

                      // Drawer button (sobre el mapa)
                      const Positioned(
                        top: 12,
                        left: 12,
                        child: HomeDrawerButton(),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * 0.3,
                  // color: Colors.red,
                ),
              ],
            ),
            // 40% PANEL DE VIAJE
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: size.height * 0.4,
                child: HomeTripPanel(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
