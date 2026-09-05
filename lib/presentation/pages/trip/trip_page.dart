import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:app_rtsg_client/application/trip_controller.dart';
import 'package:app_rtsg_client/core/theme/app_colors.dart';
import 'package:app_rtsg_client/data/models/trip_status.dart';
import 'package:app_rtsg_client/presentation/pages/trip/components/route_input_sheet.dart';
import 'package:app_rtsg_client/presentation/pages/trip/components/trip_panel.dart';
import 'package:app_rtsg_client/presentation/widgets/map_widget.dart';

class TripPage extends StatefulWidget {
  const TripPage({super.key});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  TripController get controller => Get.find<TripController>();

  // Estado visual del panel de confirmación. La lógica del viaje vive en
  // TripController.
  double _routeSheetExtent = 0.55;

  bool _onRouteSheetNotification(DraggableScrollableNotification notification) {
    final next = notification.extent;
    if ((next - _routeSheetExtent).abs() < 0.008) return false;

    setState(() => _routeSheetExtent = next);
    return false;
  }

  double _fitMaxZoomForDistance(double distanceKm) {
    if (distanceKm <= 0.8) return 15.4;
    if (distanceKm <= 1.5) return 15.0;
    if (distanceKm <= 3.0) return 14.7;
    if (distanceKm <= 5.0) return 14.4;
    if (distanceKm <= 10.0) return 14.0;
    if (distanceKm <= 20.0) return 13.5;
    if (distanceKm <= 40.0) return 13.0;
    return 12.5;
  }

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

  Future<void> _openRouteEditor() async {
    controller.openDestinationSheet();

    await Get.to(
      () => Scaffold(
        backgroundColor: AppColors.surface,
        body: RouteInputSheet(
          onClose: () => Get.back(),
          mode: RouteSelectMode.destination,
        ),
      ),
      transition: Transition.cupertino,
    );
  }

  Widget _routeSummaryCard() {
    return SizedBox(
      height: 74,
      child: Container(
        padding: const EdgeInsets.fromLTRB(13, 8, 8, 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderSoft),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RouteSummaryLine(
                    color: AppColors.brandGreen,
                    text: controller.originAddress.value,
                  ),
                  const SizedBox(height: 6),
                  _RouteSummaryLine(
                    color: AppColors.brandRed,
                    text: controller.destinationAddress.value,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            TextButton(
              onPressed: _openRouteEditor,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.brandGreen,
                minimumSize: const Size(64, 44),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Cambiar',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
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
                  destination == null &&
                  controller.status.value == TripStatus.idle;

              final mapCenter = hasRoute
                  ? route[route.length ~/ 2]
                  : (origin ?? controller.lastCenter);

              // El bounds de la ruta ya toma en cuenta la separación real entre
              // origen y destino. Además limitamos cuánto puede acercarse la
              // cámara según los kilómetros del viaje.
              final actualExtent = _routeSheetExtent.clamp(0.40, 0.70);
              final progress =
                  ((actualExtent - 0.40) / (0.70 - 0.40)).clamp(0.0, 1.0);
              final cameraBottomExtent = 0.31 + (progress * 0.10);
              final distanceKm = controller.distanceKm.value;
              final distanceMaxZoom = _fitMaxZoomForDistance(distanceKm);

              final fitPadding = EdgeInsets.fromLTRB(
                30,
                hasRoute ? 106 : 28,
                30,
                hasRoute ? (screenHeight * cameraBottomExtent) + 14 : 28,
              );

              final fitPoints = hasRoute
                  ? List<LatLng>.from(route)
                  : const <LatLng>[];

              return MapPicker(
                initialCenter: mapCenter,
                initialZoom: hasRoute ? distanceMaxZoom : 16,
                path: route,
                showPath: hasRoute,
                userPosition: origin,
                showUserMarker: origin != null && !isPickingOrigin,
                destinationPosition: destination,
                showDestinationMarker: destination != null,
                showCrosshair: isPickingOrigin,
                showAttribution: false,
                autoFit: hasRoute,
                fitPoints: fitPoints,
                fitPadding: fitPadding,
                fitMinZoom: 10.5,
                fitMaxZoom: distanceMaxZoom,
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: Obx(() {
                  final hasDestination =
                      controller.destinationLatLng.value != null;

                  if (hasDestination) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _roundBackButton(),
                        const SizedBox(width: 10),
                        Expanded(child: _routeSummaryCard()),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _roundBackButton(),
                      const Spacer(),
                      if (reservationLabel != null)
                        _reservationBadge(reservationLabel),
                    ],
                  );
                }),
              ),
            ),
          ),
          Positioned(
            top: 88,
            left: 0,
            right: 0,
            child: Center(child: _originPickerCard()),
          ),
          Obx(() {
            final hasRoute =
                controller.destinationLatLng.value != null &&
                (controller.routePoints.length >= 2 ||
                    controller.isCalculating.value);

            final extent = hasRoute ? _routeSheetExtent : 0.34;
            return Positioned(
              right: 10,
              bottom: (screenHeight * extent) + 8,
              child: _attribution(),
            );
          }),
          Obx(() {
            final hasRoute =
                controller.destinationLatLng.value != null &&
                (controller.routePoints.length >= 2 ||
                    controller.isCalculating.value);

            final sheet = DraggableScrollableSheet(
              key: ValueKey(hasRoute),
              initialChildSize: hasRoute ? 0.55 : 0.32,
              minChildSize: hasRoute ? 0.40 : 0.26,
              maxChildSize: hasRoute ? 0.70 : 0.50,
              snap: true,
              snapSizes: hasRoute
                  ? const [0.40, 0.55, 0.70]
                  : const [0.32, 0.50],
              builder: (context, scrollController) {
                return TripPanel(
                  scrollController: scrollController,
                  isReservation: isReservation,
                  reservationLabel: reservationLabel,
                );
              },
            );

            if (!hasRoute) return sheet;

            return NotificationListener<DraggableScrollableNotification>(
              onNotification: _onRouteSheetNotification,
              child: sheet,
            );
          }),
        ],
      ),
    );
  }
}

class _RouteSummaryLine extends StatelessWidget {
  final Color color;
  final String text;

  const _RouteSummaryLine({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text.isEmpty ? 'Ubicación pendiente' : text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
