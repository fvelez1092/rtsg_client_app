import 'package:app_rtsg_client/presentation/widgets/trip_metrics.dart';
import 'package:app_rtsg_client/data/models/trip_status.dart';
import 'package:app_rtsg_client/routes/rtsg_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_rtsg_client/application/trip_controller.dart';
import 'package:app_rtsg_client/presentation/widgets/map_widget.dart';

/// Conserva el controlador y la suscripción de la carrera al cambiar de vista.
class DriverTrackingPage extends StatelessWidget {
  final TripController controller;
  const DriverTrackingPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // TripPage observa el estado y decide qué vista mostrar.
    // Evita reconstrucciones simultáneas de padre e hijo al desmontar el mapa.
    final status = controller.status.value;
    final title = switch (status) {
      TripStatus.arrived => 'Tu conductor ha llegado',
      TripStatus.started => 'Viaje en curso',
      TripStatus.completed => 'Viaje finalizado',
      TripStatus.cancelled => 'Viaje cancelado',
      _ => 'Tu conductor viene en camino',
    };
    if (status == TripStatus.completed || status == TripStatus.cancelled) {
      return Scaffold(
        key: ValueKey(status),
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  status == TripStatus.cancelled
                      ? Icons.cancel_outlined
                      : Icons.check_circle_outline,
                  size: 72,
                  color: status == TripStatus.cancelled
                      ? Colors.orange
                      : Colors.green,
                ),
                const SizedBox(height: 16),
                Text(
                  'Tu viaje ha finalizado',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                Obx(
                  () => TripMetrics(
                    distanceKm: controller.activeTrip.value?.hasDistance == true
                        ? controller.activeTrip.value?.distanceKm
                        : null,
                    fare: controller.activeTrip.value?.hasFare == true
                        ? controller.activeTrip.value?.fare
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    controller.activeTrip.value = null;
                    controller.resetTrip();
                    controller.status.value = TripStatus.idle;
                    Get.offAllNamed(AppRoutes.DASHBOARD);
                  },
                  child: const Text('Volver al inicio'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      key: const ValueKey('tracking-trip'),
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final driver = controller.driverPosition.value;
              final pickup =
                  controller.originLatLng.value ??
                  controller.activeTrip.value?.origin ??
                  controller.lastCenter;
              return MapPicker(
                initialCenter: driver ?? pickup,
                initialZoom: 16,
                onChanged: (center, zoom, {required isFinal}) {},
                showCrosshair: false,
                driverPosition: driver,
                showDriverMarker: driver != null,
                destinationPosition: status == TripStatus.started
                    ? controller.destinationLatLng.value
                    : null,
                showDestinationMarker: status == TripStatus.started,
                userPosition: pickup,
                showUserMarker: true,
                autoFit: driver != null && driver != pickup,
                fitPoints: <LatLng>[pickup, if (driver != null) driver],
                fitMinZoom: 3,
                fitMaxZoom: 16,
              );
            }),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.48,
            ),
            child: SingleChildScrollView(
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Obx(() {
                    final assignment =
                        controller.activeTrip.value?.assignment ?? {};
                    final rawDriver = assignment['conductor'];
                    final driver = rawDriver is Map
                        ? rawDriver
                        : <String, dynamic>{};
                    final rawUnit = assignment['unidad'];
                    final unit = rawUnit is Map ? rawUnit : <String, dynamic>{};
                    final name =
                        driver['nombre'] ??
                        driver['name'] ??
                        driver['nombres'] ??
                        assignment['conductor_nombre'];
                    final plate =
                        unit['placa'] ?? unit['plate'] ?? assignment['placa'];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name?.toString() ?? 'Conductor asignado',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (plate != null) Text('Placa: $plate'),
                        const SizedBox(height: 12),
                        TripMetrics(
                          distanceKm:
                              controller.activeTrip.value?.hasDistance == true
                              ? controller.activeTrip.value?.distanceKm
                              : null,
                          fare: controller.activeTrip.value?.hasFare == true
                              ? controller.activeTrip.value?.fare
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.driverPosition.value == null
                              ? 'Esperando la ubicación del conductor…'
                              : 'El vehículo muestra la ubicación del conductor. '
                                    'El punto verde es tu lugar de recogida.',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.originAddress.value.isEmpty
                              ? 'Punto de recogida'
                              : controller.originAddress.value,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
