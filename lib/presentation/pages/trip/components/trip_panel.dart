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

    Get.to(
      () => Scaffold(
        backgroundColor: AppColors.surface,
        body: RouteInputSheet(
          onClose: () => Get.back(),
          mode: mode,
        ),
      ),
      transition: Transition.cupertino,
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
          _Header(
            isReservation: isReservation,
            reservationLabel: reservationLabel,
            onReset: controller.resetTrip,
          ),
          const SizedBox(height: 16),
          _RouteInputs(onOpen: _openLocation),
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
                padding: EdgeInsets.symmetric(vertical: 24),
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

            return const _RideConfiguration();
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
            final status = controller.status.value;
            if (status != TripStatus.idle) return const SizedBox.shrink();

            final enabled = controller.canCreateTrip;
            final hasRoute = controller.distanceKm.value > 0;

            return SizedBox(
              width: double.infinity,
              height: 58,
              child: FilledButton(
                onPressed: enabled ? controller.createTrip : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandGreen,
                  foregroundColor: AppColors.surface,
                  disabledBackgroundColor: AppColors.borderSoft,
                  disabledForegroundColor: AppColors.textSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  hasRoute
                      ? '${isReservation ? 'Programar' : 'Solicitar'}  •  \$${controller.finalFare.toStringAsFixed(2)}'
                      : (isReservation ? 'Programar viaje' : 'Solicitar viaje'),
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

class _Header extends GetView<TripController> {
  final bool isReservation;
  final String? reservationLabel;
  final VoidCallback onReset;

  const _Header({
    required this.isReservation,
    required this.reservationLabel,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
            onPressed: onReset,
            icon: const Icon(Icons.close_rounded),
          );
        }),
      ],
    );
  }
}

class _RouteInputs extends GetView<TripController> {
  final void Function(RouteSelectMode mode) onOpen;

  const _RouteInputs({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              onTap: () => onOpen(RouteSelectMode.origin),
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
              onTap: () => onOpen(RouteSelectMode.destination),
            ),
          ),
        ],
      ),
    );
  }
}

class _RideConfiguration extends GetView<TripController> {
  const _RideConfiguration();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Row(
            children: [
              _Metric(
                icon: Icons.route_rounded,
                value: '${controller.distanceKm.value.toStringAsFixed(1)} km',
                label: 'Distancia',
              ),
              Container(width: 1, height: 34, color: AppColors.borderSoft),
              _Metric(
                icon: Icons.schedule_rounded,
                value: '${controller.durationMin.value} min',
                label: 'Trayecto',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionTitle(
          title: 'Elige tu servicio',
          subtitle: 'Selecciona la categoría que prefieras para este viaje.',
        ),
        const SizedBox(height: 10),
        Obx(
          () => _CategoryCard(
            category: TripCategory.normal,
            title: 'Normal',
            subtitle: 'Servicio RTSG para tu viaje diario',
            icon: Icons.local_taxi_rounded,
            fare: controller.normalFare,
            selected: controller.selectedCategory.value == TripCategory.normal,
            onTap: () => controller.selectCategory(TripCategory.normal),
          ),
        ),
        const SizedBox(height: 9),
        Obx(
          () => _CategoryCard(
            category: TripCategory.vip,
            title: 'VIP / Ejecutivo',
            subtitle: 'Mayor comodidad y atención preferente',
            icon: Icons.workspace_premium_rounded,
            fare: controller.vipFare,
            selected: controller.selectedCategory.value == TripCategory.vip,
            onTap: () => controller.selectCategory(TripCategory.vip),
          ),
        ),
        const SizedBox(height: 20),
        const _SectionTitle(
          title: 'Mejora tu oferta',
          subtitle:
              'Si hay alta demanda, puedes aumentar el valor para facilitar que una unidad acepte el viaje.',
        ),
        const SizedBox(height: 10),
        Obx(() {
          final selected = controller.priceBoost.value;

          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TripController.priceBoostOptions.map((amount) {
              final active = selected == amount;
              final label = amount == 0
                  ? 'Sin extra'
                  : '+\$${amount.toStringAsFixed(2)}';

              return ChoiceChip(
                selected: active,
                onSelected: (_) => controller.setPriceBoost(amount),
                label: Text(label),
                selectedColor: AppColors.brandGreen.withValues(alpha: 0.12),
                backgroundColor: AppColors.surface,
                side: BorderSide(
                  color: active ? AppColors.brandGreen : AppColors.borderSoft,
                ),
                labelStyle: TextStyle(
                  color: active
                      ? AppColors.brandGreen
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              );
            }).toList(),
          );
        }),
        const SizedBox(height: 10),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.sell_outlined,
                  size: 20,
                  color: AppColors.brandGreen,
                ),
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'Oferta total del viaje',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '\$${controller.finalFare.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const _SectionTitle(
          title: 'Método de pago',
          subtitle: 'Por ahora los viajes se pagan únicamente en efectivo.',
        ),
        const SizedBox(height: 10),
        const _PaymentMethodCard(
          icon: Icons.payments_rounded,
          title: 'Efectivo',
          subtitle: 'Paga directamente al conductor',
          enabled: true,
        ),
        const SizedBox(height: 8),
        const _PaymentMethodCard(
          icon: Icons.account_balance_wallet_rounded,
          title: 'Billetera RTSG',
          subtitle: 'Próximamente',
          enabled: false,
        ),
        const SizedBox(height: 8),
        const _PaymentMethodCard(
          icon: Icons.credit_card_rounded,
          title: 'Tarjeta',
          subtitle: 'Próximamente',
          enabled: false,
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final TripCategory category;
  final String title;
  final String subtitle;
  final IconData icon;
  final double fare;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.fare,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.brandGreen : AppColors.borderSoft,
              width: selected ? 1.7 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: category == TripCategory.vip
                      ? AppColors.taxiYellow.withValues(alpha: 0.22)
                      : AppColors.brandGreen.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 29,
                  color: category == TripCategory.vip
                      ? AppColors.textPrimary
                      : AppColors.brandGreen,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (selected) ...[
                          const SizedBox(width: 7),
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: AppColors.brandGreen,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '\$${fare.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;

  const _PaymentMethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = enabled
        ? AppColors.textPrimary
        : AppColors.textSecondary.withValues(alpha: 0.70);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: enabled ? AppColors.surface : AppColors.inputFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled ? AppColors.brandGreen : AppColors.borderSoft,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: enabled
                  ? AppColors.brandGreen.withValues(alpha: 0.10)
                  : AppColors.borderSoft.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: enabled ? AppColors.brandGreen : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: enabled
                        ? AppColors.textSecondary
                        : AppColors.textSecondary.withValues(alpha: 0.70),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (enabled)
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.brandGreen,
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.borderSoft,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Pronto',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
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
                      color: AppColors.textPrimary,
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
