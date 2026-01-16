import 'package:app_rtsg_client/application/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_rtsg_client/presentation/widgets/map_widget.dart';
import 'package:app_rtsg_client/core/theme/app_colors.dart';

import 'components/home_drawer_button.dart';
import 'components/home_trip_panel.dart';
import 'components/home_app_drawer.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HomeAppDrawer(),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Obx(() {
                    return MapPicker(
                      initialCenter: controller.lastCenter,
                      initialZoom: 16.0,
                      centerLabel: controller.centerLabel.value,
                      onChanged: (center, zoom, {required isFinal}) {
                        controller.onMapChanged(center, zoom, isFinal: isFinal);
                      },
                    );
                  }),
                  const Positioned(
                    top: 12,
                    left: 12,
                    child: HomeDrawerButton(),
                  ),
                ],
              ),
            ),
            const Expanded(flex: 5, child: HomeTripPanel()),
          ],
        ),
      ),
    );
  }
}
