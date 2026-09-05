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
      child: Obx(() {
        final hasDestination = controller.destinationLatLng.value != null;
        final calculating = controller.isCalculating.value;
        final hasRoute =
            controller.distanceKm.value > 0 && controller.durationMin.value > 0;

        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 9, 16, 22),
          children: [
            const _Handle(),
            if (!hasDestination)
              _SearchContent(
                isReservation: isReservation,
                reservationLabel: reservationLabel,
                onOpenLocation: _openLocation,
              )
            else if (calculating || !hasRoute)
              _CalculatingContent(
                onChange: () => _openLocation(RouteSelectMode.destination),
              )
            else
              _ConfirmationContent(
                isReservation: isReservation,
                reservationLabel: reservationLabel,
              ),
          ],
        );
      }),
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.borderSoft,
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}

class _SearchContent extends StatelessWidget {
  final bool isReservation;
  final String? reservationLabel;
  final void Function(RouteSelectMode mode) onOpenLocation;

  const _SearchContent({
    required this.isReservation,
    required this.reservationLabel,
    required this.onOpenLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 14),
        _RouteInputs(onOpen: onOpenLocation),
        const SizedBox(height: 12),
        _HintCard(onTap: () => onOpenLocation(RouteSelectMode.destination)),
      ],
    );
  }
}

class _CalculatingContent extends StatelessWidget {
  final VoidCallback onChange;

  const _CalculatingContent({required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.brandGreen,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Calculando la mejor ruta…',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Estamos preparando las opciones disponibles para tu viaje.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onChange,
            child: const Text('Cambiar destino'),
          ),
        ],
      ),
    );
  }
}

class _ConfirmationContent extends GetView<TripController> {
  final bool isReservation;
  final String? reservationLabel;

  const _ConfirmationContent({
    required this.isReservation,
    required this.reservationLabel,
  });

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

  Future<void> _showPaymentOptions(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Método de pago',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Por ahora solo está disponible el pago en efectivo.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                const _PaymentOptionTile(
                  icon: Icons.payments_rounded,
                  title: 'Efectivo',
                  subtitle: 'Paga directamente al conductor',
                  selected: true,
                  enabled: true,
                ),
                const SizedBox(height: 8),
                const _PaymentOptionTile(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Billetera RTSG',
                  subtitle: 'Próximamente',
                  selected: false,
                  enabled: false,
                ),
                const SizedBox(height: 8),
                const _PaymentOptionTile(
                  icon: Icons.credit_card_rounded,
                  title: 'Tarjeta',
                  subtitle: 'Próximamente',
                  selected: false,
                  enabled: false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = controller.status.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isReservation ? 'Confirma tu reserva' : 'Elige cómo viajar',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          isReservation && reservationLabel != null
              ? reservationLabel!
              : 'Selecciona una categoría y confirma tu viaje.',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 10),
        _TripMetrics(
          distanceKm: controller.distanceKm.value,
          durationMin: controller.durationMin.value,
        ),
        const SizedBox(height: 12),
        const _CompactSectionTitle(title: 'Elige tu servicio'),
        const SizedBox(height: 7),
        _CategoryCard(
          category: TripCategory.normal,
          title: 'Normal',
          subtitle: 'Servicio RTSG para tu viaje diario',
          icon: Icons.local_taxi_rounded,
          fare: controller.normalFare,
          selected: controller.selectedCategory.value == TripCategory.normal,
          onTap: () => controller.selectCategory(TripCategory.normal),
        ),
        const SizedBox(height: 7),
        _CategoryCard(
          category: TripCategory.vip,
          title: 'VIP / Ejecutivo',
          subtitle: 'Mayor comodidad y atención preferente',
          icon: Icons.workspace_premium_rounded,
          fare: controller.vipFare,
          selected: controller.selectedCategory.value == TripCategory.vip,
          onTap: () => controller.selectCategory(TripCategory.vip),
        ),
        const SizedBox(height: 12),
        const _OfferHeader(),
        const SizedBox(height: 7),
        _PriceBoostRow(
          selected: controller.priceBoost.value,
          onChanged: controller.setPriceBoost,
        ),
        const SizedBox(height: 12),
        _CompactPaymentTile(onTap: () => _showPaymentOptions(context)),
        if (status != TripStatus.idle) ...[
          const SizedBox(height: 12),
          _StatusCard(
            status: status,
            text: _statusText(status),
            onCancel:
                (status == TripStatus.searching || status == TripStatus.accepted)
                ? controller.cancelTrip
                : null,
          ),
        ],
        const SizedBox(height: 12),
        if (status == TripStatus.idle)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: controller.canCreateTrip ? controller.createTrip : null,
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
                '${isReservation ? 'Programar' : 'Solicitar'}  •  \$${controller.finalFare.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
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
          _LocationRow(
            dotColor: AppColors.brandGreen,
            icon: Icons.my_location_rounded,
            label: 'Punto de partida',
            value: controller.originAddress.value.isEmpty
                ? 'Usar mi ubicación'
                : controller.originAddress.value,
            onTap: () => onOpen(RouteSelectMode.origin),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 54),
            child: Divider(height: 1, color: AppColors.borderSoft),
          ),
          _LocationRow(
            dotColor: AppColors.brandRed,
            icon: Icons.location_on_rounded,
            label: 'Destino',
            value: controller.destinationAddress.value.isEmpty
                ? '¿A dónde vas?'
                : controller.destinationAddress.value,
            emphasize: controller.destinationAddress.value.isEmpty,
            onTap: () => onOpen(RouteSelectMode.destination),
          ),
        ],
      ),
    );
  }
}

class _TripMetrics extends StatelessWidget {
  final double distanceKm;
  final int durationMin;

  const _TripMetrics({required this.distanceKm, required this.durationMin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          _Metric(
            icon: Icons.route_rounded,
            value: '${distanceKm.toStringAsFixed(1)} km',
            label: 'Distancia',
          ),
          Container(width: 1, height: 30, color: AppColors.borderSoft),
          _Metric(
            icon: Icons.schedule_rounded,
            value: '$durationMin min',
            label: 'Trayecto',
          ),
        ],
      ),
    );
  }
}

class _CompactSectionTitle extends StatelessWidget {
  final String title;

  const _CompactSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _OfferHeader extends StatelessWidget {
  const _OfferHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _CompactSectionTitle(title: 'Mejora tu oferta')),
        Tooltip(
          message:
              'En momentos de alta demanda puedes aumentar el valor para facilitar que una unidad acepte el viaje.',
          triggerMode: TooltipTriggerMode.tap,
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(
              Icons.info_outline_rounded,
              size: 19,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _PriceBoostRow extends StatelessWidget {
  final double selected;
  final ValueChanged<double> onChanged;

  const _PriceBoostRow({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 39,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: TripController.priceBoostOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final amount = TripController.priceBoostOptions[index];
          final active = selected == amount;
          final label = amount == 0
              ? 'Sin extra'
              : '+\$${amount.toStringAsFixed(2)}';

          return ChoiceChip(
            selected: active,
            onSelected: (_) => onChanged(amount),
            label: Text(label),
            visualDensity: VisualDensity.compact,
            selectedColor: AppColors.brandGreen.withValues(alpha: 0.12),
            backgroundColor: AppColors.surface,
            side: BorderSide(
              color: active ? AppColors.brandGreen : AppColors.borderSoft,
            ),
            labelStyle: TextStyle(
              color: active ? AppColors.brandGreen : AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          );
        },
      ),
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
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.brandGreen : AppColors.borderSoft,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: category == TripCategory.vip
                      ? AppColors.taxiYellow.withValues(alpha: 0.22)
                      : AppColors.brandGreen.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  size: 25,
                  color: category == TripCategory.vip
                      ? AppColors.textPrimary
                      : AppColors.brandGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (selected) ...[
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 17,
                            color: AppColors.brandGreen,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
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
              const SizedBox(width: 8),
              Text(
                '\$${fare.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
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

class _CompactPaymentTile extends StatelessWidget {
  final VoidCallback onTap;

  const _CompactPaymentTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.payments_rounded,
                size: 22,
                color: AppColors.brandGreen,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Efectivo',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final bool enabled;

  const _PaymentOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: enabled ? AppColors.surface : AppColors.inputFill,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: selected ? AppColors.brandGreen : AppColors.borderSoft,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
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
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: enabled
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (selected)
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.brandGreen,
            )
          else if (!enabled)
            const Text(
              'Pronto',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final TripStatus status;
  final String text;
  final VoidCallback? onCancel;

  const _StatusCard({
    required this.status,
    required this.text,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final loading =
        status == TripStatus.searching || status == TripStatus.creating;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.brandGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.brandGreen.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          if (loading)
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
          if (onCancel != null)
            TextButton(
              onPressed: onCancel,
              child: const Text('Cancelar'),
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
          Icon(icon, size: 19, color: AppColors.brandGreen),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
