import 'package:app_rtsg_client/application/trip_controller.dart';
import 'package:app_rtsg_client/core/theme/app_colors.dart';
import 'package:app_rtsg_client/data/models/trip_status.dart';
import 'package:app_rtsg_client/presentation/pages/trip/components/route_input_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TripPanel extends GetView<TripController> {
  final ScrollController? scrollController;
  final bool isReservation;
  final String? reservationLabel;

  const TripPanel({
    super.key,
    this.scrollController,
    this.isReservation = false,
    this.reservationLabel,
  });

  void _openLocation(RouteSelectMode mode) {
    controller.openDestinationSheet();
    Get.bottomSheet(
      RouteInputSheet(
        onClose: () => Get.back(),
        mode: mode,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  String _statusText(TripStatus status) {
    return switch (status) {
      TripStatus.creating => 'Preparando tu solicitud…',
      TripStatus.searching => 'Buscando un conductor cerca de ti…',
      TripStatus.accepted => 'Conductor asignado',
      TripStatus.arrived => 'Tu conductor llegó al punto de partida',
      TripStatus.started => 'Viaje en curso',
      TripStatus.completed => 'Viaje finalizado',
      TripStatus.cancelled => 'Viaje cancelado',
      TripStatus.failed => 'No pudimos crear el viaje',
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 22,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppColors.borderSoft,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isReservation ? 'Programa tu viaje' : '¿A dónde vamos?',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isReservation && reservationLabel != null
                          ? reservationLabel!
                          : 'Selecciona tu origen y destino',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() {
                final hasRoute =
                    controller.destinationLatLng.value != null ||
                    controller.destinationAddress.value.trim().isNotEmpty;

                if (!hasRoute) return const SizedBox.shrink();

                return IconButton.filledTonal(
                  tooltip: 'Limpiar ruta',
                  onPressed: controller.resetTrip,
                  icon: const Icon(Icons.close_rounded),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: Column(
              children: [
                Obx(
                  () => _LocationRow(
                    dotColor: AppColors.brandGreen,
                    icon: Icons.my_location_rounded,
                    label: 'Punto de partida',
                    value: controller.originAddress.value.isEmpty
                        ? 'Usar mi ubicación'
                        : controller.originAddress.value,
                    onTap: () => _openLocation(RouteSelectMode.origin),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 54),
                  child: Divider(height: 1, color: AppColors.borderSoft),
                ),
                Obx(
                  () => _LocationRow(
                    dotColor: AppColors.brandRed,
                    icon: Icons.location_on_rounded,
                    label: 'Destino',
                    value: controller.destinationAddress.value.isEmpty
                        ? '¿A dónde vas?'
                        : controller.destinationAddress.value,
                    emphasize: controller.destinationAddress.value.isEmpty,
                    onTap: () => _openLocation(RouteSelectMode.destination),
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            final calculating = controller.isCalculating.value;
            final hasRoute =
                controller.distanceKm.value > 0 &&
                controller.durationMin.value > 0;

            if (!calculating && !hasRoute) {
              return Padding(
                padding: const EdgeInsets.only(top: 14),
                child: _HintCard(
                  onTap: () => _openLocation(RouteSelectMode.destination),
                ),
              );
            }

            if (calculating) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.brandGreen,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Calculando la mejor ruta…',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                const SizedBox(height: 16),
                _RideOptionCard(
                  fare: controller.estimatedFare.value,
                  durationMin: controller.durationMin.value,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSoft),
                  ),
                  child: Row(
                    children: [
                      _Metric(
                        icon: Icons.route_rounded,
                        value:
                            '${controller.distanceKm.value.toStringAsFixed(1)} km',
                        label: 'Distancia',
                      ),
                      Container(
                        width: 1,
                        height: 34,
                        color: AppColors.borderSoft,
                      ),
                      _Metric(
                        icon: Icons.schedule_rounded,
                        value: '${controller.durationMin.value} min',
                        label: 'Trayecto',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const _PaymentTile(),
              ],
            );
          }),
          Obx(() {
            final status = controller.status.value;
            if (status == TripStatus.idle) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.brandGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.brandGreen.withValues(alpha: 0.20),
                ),
              ),
              child: Row(
                children: [
                  if (status == TripStatus.searching ||
                      status == TripStatus.creating)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.brandGreen,
                      ),
                    )
                  else
                    const Icon(
                      Icons.local_taxi_rounded,
                      color: AppColors.brandGreen,
                    ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      _statusText(status),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (status == TripStatus.searching ||
                      status == TripStatus.accepted)
                    TextButton(
                      onPressed: controller.cancelTrip,
                      child: const Text('Cancelar'),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          Obx(() {
            final enabled = controller.canCreateTrip;
            final status = controller.status.value;

            if (status != TripStatus.idle) {
              return const SizedBox.shrink();
            }

            return SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: enabled ? controller.createTrip : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandGreen,
                  foregroundColor: AppColors.surface,
                  disabledBackgroundColor: AppColors.borderSoft,
                  disabledForegroundColor: AppColors.textSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                child: Text(
                  isReservation ? 'Programar viaje' : 'Solicitar viaje',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final Color dotColor;
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool emphasize;

  const _LocationRow({
    required this.dotColor,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
                boxShadow: const [
                  BoxShadow(color: AppColors.shadow, blurRadius: 4),
                ],
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: emphasize
                          ? AppColors.textPrimary
                          : AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(icon, color: dotColor, size: 21),
          ],
        ),
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  final VoidCallback onTap;

  const _HintCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.brandGreen.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: AppColors.brandGreen),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Elige un destino para ver la ruta, tiempo y tarifa estimada.',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.brandGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RideOptionCard extends StatelessWidget {
  final double fare;
  final int durationMin;

  const _RideOptionCard({required this.fare, required this.durationMin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.brandGreen, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.taxiYellow.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_taxi_rounded,
              color: AppColors.textPrimary,
              size: 31,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RTSG Taxi',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Viaje cómodo · aprox. $durationMin min',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${fare.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _Metric({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.brandGreen),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            color: AppColors.brandGreen,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Método de pago',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Efectivo / Billetera RTSG',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
