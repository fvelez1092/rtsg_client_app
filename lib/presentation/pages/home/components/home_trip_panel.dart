import 'package:app_rtsg_client/application/trip_controller.dart';
import 'package:app_rtsg_client/data/models/trip_status.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_rtsg_client/core/theme/app_colors.dart';
import 'route_input_sheet.dart';

class HomeTripPanel extends GetView<TripController> {
  const HomeTripPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.borderSoft,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),

                    // ✅ Header con botón cancelar (icon)
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Nueva carrera',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Obx(() {
                          final hasSomething =
                              controller.destinationLatLng.value != null ||
                              controller.destinationAddress.value
                                  .trim()
                                  .isNotEmpty ||
                              controller.distanceKm.value > 0 ||
                              controller.durationMin.value > 0;

                          if (!hasSomething) return const SizedBox.shrink();

                          return Material(
                            color: AppColors.inputFill,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: controller.resetTrip,
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  Icons.close,
                                  size: 20,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Origen (mapa, pero editable)
                    Obx(
                      () => _InfoTile(
                        icon: Icons.my_location,
                        title: 'Origen',
                        value: controller.originAddress.value.isEmpty
                            ? 'Selecciona en el mapa'
                            : controller.originAddress.value,
                        onTap: () {
                          controller.openDestinationSheet();
                          Get.bottomSheet(
                            RouteInputSheet(
                              onClose: () => Get.back(),
                              mode: RouteSelectMode.origin,
                            ),
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Destino
                    Obx(
                      () => _InfoTile(
                        icon: Icons.location_on_outlined,
                        title: 'Destino',
                        value: controller.destinationAddress.value.isEmpty
                            ? '¿A dónde vas?'
                            : controller.destinationAddress.value,
                        onTap: () {
                          controller.openDestinationSheet();
                          Get.bottomSheet(
                            RouteInputSheet(
                              onClose: () => Get.back(),
                              mode: RouteSelectMode.destination,
                            ),
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    Obx(() {
                      final noDestination =
                          controller.destinationLatLng.value == null &&
                          controller.destinationAddress.value.trim().isEmpty;

                      if (!noDestination) return const SizedBox.shrink();

                      return Column(
                        children: const [
                          _FrequentItem(
                            icon: Icons.location_on,
                            color: Colors.blue,
                            title: "Casa",
                            subtitle: "Av. 5 de Junio y Paso Lateral",
                            onTap: null,
                          ),
                          _FrequentItem(
                            icon: Icons.location_on,
                            color: Colors.blue,
                            title: "Trabajo",
                            subtitle: "Edificio Previsora",
                            onTap: null,
                          ),
                        ],
                      );
                    }),

                    // Resumen
                    Obx(() {
                      final calculating = controller.isCalculating.value;
                      final hasData =
                          controller.distanceKm.value > 0 &&
                          controller.durationMin.value > 0;

                      if (!hasData && !calculating) {
                        return const SizedBox.shrink();
                      }

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderSoft),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Resumen del viaje',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (calculating)
                              const Text(
                                'Calculando ruta…',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: _MiniStat(
                                      label: 'Distancia',
                                      value:
                                          '${controller.distanceKm.value.toStringAsFixed(1)} km',
                                    ),
                                  ),
                                  Expanded(
                                    child: _MiniStat(
                                      label: 'Tiempo',
                                      value:
                                          '${controller.durationMin.value} min',
                                    ),
                                  ),
                                  Expanded(
                                    child: _MiniStat(
                                      label: 'Tarifa',
                                      value:
                                          '\$ ${controller.estimatedFare.value.toStringAsFixed(2)}',
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      );
                    }),

                    const Spacer(),
                    Obx(() {
                      final st = controller.status.value;
                      if (st == TripStatus.idle) return const SizedBox.shrink();

                      String text;
                      switch (st) {
                        case TripStatus.creating:
                          text = 'Creando carrera…';
                          break;
                        case TripStatus.searching:
                          text = 'Buscando conductor…';
                          break;
                        case TripStatus.accepted:
                          text = 'Conductor aceptó la carrera ✅';
                          break;
                        case TripStatus.arrived:
                          text = 'Conductor llegó al origen';
                          break;
                        case TripStatus.started:
                          text = 'Viaje en curso…';
                          break;
                        case TripStatus.completed:
                          text = 'Viaje finalizado 🎉';
                          break;
                        case TripStatus.cancelled:
                          text = 'Carrera cancelada';
                          break;
                        case TripStatus.failed:
                          text = 'Error al crear carrera';
                          break;
                        default:
                          text = '';
                          break;
                      }

                      return Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSoft),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                text,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (st == TripStatus.searching ||
                                st == TripStatus.accepted)
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: controller.cancelTrip,
                              ),
                          ],
                        ),
                      );
                    }),
                    const Spacer(),
                    Obx(() {
                      final enabled = controller.canCreateTrip;
                      return SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: enabled ? controller.createTrip : null,
                          child: const Text('Solicitar taxi'),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.inputFill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _FrequentItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _FrequentItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    leading: CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.08),
      child: Icon(icon, color: color),
    ),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    subtitle: Text(subtitle),
    onTap: onTap,
  );
}
