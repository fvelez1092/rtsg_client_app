import 'package:app_rtsg_client/presentation/pages/trip/components/trip_panel.dart';
import 'package:app_rtsg_client/presentation/widgets/app_drawer.dart';
import 'package:app_rtsg_client/presentation/widgets/drawer_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_rtsg_client/application/home2_controller.dart';
import 'package:app_rtsg_client/application/trip_controller.dart';
import 'package:app_rtsg_client/presentation/widgets/map_widget.dart';
import 'package:app_rtsg_client/core/theme/app_colors.dart';

class TripPage extends GetView<Home2Controller> {
  const TripPage({super.key});

  Widget _buildCenterLabel(String label) {
    return IgnorePointer(
      child: Center(
        child: Transform.translate(
          offset: const Offset(0, -46),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: label.trim().isEmpty ? 0 : 1,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 320),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 12,
                    color: AppColors.shadow,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.place_outlined,
                    size: 16,
                    color: AppColors.brandGreen,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return IgnorePointer(
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.taxiYellow,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Calculando ruta…',
                style: TextStyle(color: AppColors.surface, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReservationBadge(String label) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 235),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(13),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.event_available_rounded,
            size: 18,
            color: AppColors.brandGreen,
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Viaje programado',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trip = Get.find<TripController>();
    final args = Get.arguments;
    final reservationLabel = args is Map && args['isReservation'] == true
        ? (args['reservationLabel'] ?? 'Reserva programada').toString()
        : null;

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
                    final route = trip.routePoints;

                    return Stack(
                      children: [
                        MapPicker(
                          initialCenter: controller.lastCenter,
                          initialZoom: 16,
                          path: route,
                          showPath: route.length >= 2,
                          userPosition: origin,
                          showUserMarker: origin != null,
                          polylineColor: AppColors.brandGreen,
                          onChanged: (center, zoom, {required isFinal}) {
                            controller.onMapChanged(
                              center,
                              zoom,
                              isFinal: isFinal,
                            );
                          },
                        ),
                        Positioned.fill(
                          child: _buildCenterLabel(
                            controller.centerLabel.value,
                          ),
                        ),
                        if (trip.isCalculating.value)
                          Positioned.fill(child: _buildLoadingOverlay()),
                      ],
                    );
                  }),
                  const Positioned(top: 12, left: 12, child: AppDrawerButton()),
                  if (reservationLabel != null)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _buildReservationBadge(reservationLabel),
                    ),
                ],
              ),
            ),
            const Expanded(flex: 4, child: TripPanel()),
          ],
        ),
      ),
    );
  }
}
