import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_rtsg_client/application/trip_controller.dart';
import 'package:app_rtsg_client/core/theme/app_colors.dart';
import 'package:app_rtsg_client/data/models/trip_status.dart';
import 'package:app_rtsg_client/presentation/pages/trip/components/trip_panel.dart';
import 'package:app_rtsg_client/presentation/widgets/map_widget.dart';

class TripPage extends GetView<TripController> {
  const TripPage({super.key});

  Widget _roundBackButton() {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: AppColors.shadow,
      child: InkWell(
        onTap: () => Get.back(),
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(
            Icons.arrow_back_rounded,
            size: 22,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _reservationBadge(String label) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 245),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.brandGreen.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              size: 19,
              color: AppColors.brandGreen,
            ),
          ),
          const SizedBox(width: 9),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Viaje programado',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
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

  Widget _attribution() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        '© OpenStreetMap contributors',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 9,
        ),
      ),
    );
  }

  Widget _originPickerCard() {
    return Obx(() {
      final isPickingOrigin =
          controller.destinationLatLng.value == null &&
          controller.status.value == TripStatus.idle;

      if (!isPickingOrigin) return const SizedBox.shrink();

      final resolving = controller.isResolvingOrigin.value;
      final address = controller.centerLabel.value;

      return Container(
        constraints: const BoxConstraints(maxWidth: 310),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.brandGreen.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: resolving
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.brandGreen,
                      ),
                    )
                  : const Icon(
                      Icons.my_location_rounded,
                      size: 20,
                      color: AppColors.brandGreen,
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Punto de partida',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Mueve el mapa para ajustar la ubicación',
                    style: TextStyle(
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final isReservation = args is Map && args['isReservation'] == true;
    final reservationLabel = isReservation
        ? (args['reservationLabel'] ?? 'Reserva programada').toString()
        : null;

    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Obx(() {
              final origin = controller.originLatLng.value;
              final destination = controller.destinationLatLng.value;
              final route = controller.routePoints;
              final hasRoute = route.length >= 2;
              final isPickingOrigin =
                  destination == null && controller.status.value == TripStatus.idle;

              final mapCenter = hasRoute
                  ? route[route.length ~/ 2]
                  : (origin ?? controller.lastCenter);

              return MapPicker(
                initialCenter: mapCenter,
                initialZoom: hasRoute ? 14.5 : 16,
                path: route,
                showPath: hasRoute,
                userPosition: origin,
                showUserMarker: origin != null && !isPickingOrigin,
                destinationPosition: destination,
                showDestinationMarker: destination != null,
                showCrosshair: isPickingOrigin,
                showAttribution: false,
                polylineColor: AppColors.brandGreen,
                onChanged: (center, zoom, {required isFinal}) {
                  if (!isPickingOrigin) return;
                  controller.onMapChanged(
                    center,
                    zoom,
                    isFinal: isFinal,
                  );
                },
              );
            }),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _roundBackButton(),
                  const Spacer(),
                  if (reservationLabel != null)
                    _reservationBadge(reservationLabel),
                ],
              ),
            ),
          ),
          Positioned(
            top: 88,
            left: 0,
            right: 0,
            child: Center(child: _originPickerCard()),
          ),
          Positioned(
            right: 10,
            bottom: screenHeight * 0.39,
            child: _attribution(),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.38,
            minChildSize: 0.30,
            maxChildSize: 0.72,
            snap: true,
            builder: (context, scrollController) {
              return TripPanel(
                scrollController: scrollController,
                isReservation: isReservation,
                reservationLabel: reservationLabel,
              );
            },
          ),
        ],
      ),
    );
  }
}
