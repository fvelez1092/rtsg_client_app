import 'package:app_manporcar_client/data/models/trips/trip_model.dart';
import 'package:flutter/material.dart';

class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback? onTap;
  final VoidCallback? onContact;
  final VoidCallback? onMap;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onRate;
  final VoidCallback? onReceipt;
  final VoidCallback? onRebook;

  const TripCard({
    super.key,
    required this.trip,
    this.onTap,
    this.onContact,
    this.onMap,
    this.onEdit,
    this.onCancel,
    this.onRate,
    this.onReceipt,
    this.onRebook,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 170,
              decoration: BoxDecoration(
                color: Trip.leftBorder(trip.status),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _stateCircleIcon(trip.status),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trip.name,
                                style: const TextStyle(
                                  color: Color(0xFF1b0130),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _StatusBadge(status: trip.status),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              trip.requestedDate.day == DateTime.now().day
                                  ? 'Hoy'
                                  : (trip.requestedDate.day ==
                                            DateTime.now().day + 1
                                        ? 'Mañana'
                                        : '${trip.requestedDate.day}'),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              trip.estimatedTime
                                  .toString()
                                  .split('.')
                                  .first
                                  .padLeft(8, '0')
                                  .substring(0, 5),
                              style: const TextStyle(
                                color: Color(0xFF1b0130),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _dotLine(
                      dotColor: Colors.green,
                      label: 'Origen',
                      value: trip.departureAddress,
                    ),
                    const SizedBox(height: 8),
                    _dotLine(
                      dotColor: Colors.red,
                      label: 'Destino',
                      value: trip.destinationAddress,
                    ),
                    const SizedBox(height: 12),
                    if (trip.status == TripStatus.inProgress &&
                        trip.passengerCount != null &&
                        trip.luggageCount != null)
                      _noteBox(
                        icon: Icons.group_rounded,
                        bg: const Color(0xFFEFF6FF),
                        border: const Color(0xFFBFDBFE),
                        text:
                            '${trip.passengerCount} de ${trip.luggageCount} puestos ocupados',
                        textColor: const Color(0xFF1E40AF),
                      ),
                    if (trip.status == TripStatus.pending &&
                        (trip.notes?.isNotEmpty ?? false))
                      _noteBox(
                        icon: Icons.schedule_rounded,
                        bg: const Color(0xFFFFFBEB),
                        border: const Color(0xFFFDE68A),
                        text: trip.route!,
                        textColor: const Color(0xFF92400E),
                      ),
                    if (trip.status == TripStatus.cancelled &&
                        (trip.route?.isNotEmpty ?? false))
                      _noteBox(
                        icon: Icons.info_outline_rounded,
                        bg: const Color(0xFFFFEEEE),
                        border: const Color(0xFFFCA5A5),
                        text: trip.route!,
                        textColor: const Color(0xFF991B1B),
                      ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFF3F4F6)),
                        ),
                      ),
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.attach_money,
                                size: 20,
                                color: Color(0xFFec6206),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                Trip.priceLabel(trip),
                                style: TextStyle(
                                  color: trip.status == TripStatus.cancelled
                                      ? Colors.grey
                                      : const Color(0xFF1b0130),
                                  fontWeight: FontWeight.w700,
                                  decoration:
                                      trip.status == TripStatus.cancelled
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Wrap(
                            spacing: 8,
                            children: [
                              if (onContact != null)
                                _chipBtn(
                                  icon: Icons.phone_rounded,
                                  label: 'Contactar',
                                  onTap: onContact!,
                                  filled: false,
                                ),
                              if (onMap != null)
                                _chipBtn(
                                  icon: Icons.route_rounded,
                                  label: 'Mapa',
                                  onTap: onMap!,
                                  filled: false,
                                ),
                              if (onEdit != null)
                                _chipBtn(
                                  icon: Icons.edit_rounded,
                                  label: 'Editar',
                                  onTap: onEdit!,
                                  filled: true,
                                ),
                              if (onCancel != null)
                                _chipBtn(
                                  icon: Icons.close_rounded,
                                  label: 'Cancelar',
                                  onTap: onCancel!,
                                  filled: false,
                                  color: const Color(0xFFDC2626),
                                  bg: const Color(0xFFFFE4E6),
                                  textColor: const Color(0xFFB91C1C),
                                ),
                              if (onRate != null)
                                _chipBtn(
                                  icon: Icons.star_rate_rounded,
                                  label: 'Calificar',
                                  onTap: onRate!,
                                  filled: false,
                                  bg: const Color(0xFFFFF7ED),
                                  textColor: const Color(0xFF92400E),
                                ),
                              if (onReceipt != null)
                                _chipBtn(
                                  icon: Icons.receipt_long_rounded,
                                  label: 'Recibo',
                                  onTap: onReceipt!,
                                  filled: true,
                                ),
                              if (onRebook != null)
                                _chipBtn(
                                  icon: Icons.refresh_rounded,
                                  label: 'Reservar de nuevo',
                                  onTap: onRebook!,
                                  filled: true,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stateCircleIcon(TripStatus s) {
    IconData icon;
    Color bg;
    Color fg;
    switch (s) {
      case TripStatus.pending:
        icon = Icons.group_rounded;
        bg = const Color(0xFFFFF7ED);
        fg = const Color(0xFFF59E0B);
        break;
      case TripStatus.verified:
        icon = Icons.person_rounded;
        bg = const Color(0xFFEFFDF5);
        fg = const Color(0xFF10B981);
        break;
      case TripStatus.inProgress:
        icon = Icons.directions_car_rounded;
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF3B82F6);
        break;
      case TripStatus.completed:
        icon = Icons.check_rounded;
        bg = const Color(0xFFF3F4F6);
        fg = const Color(0xFF6B7280);
        break;
      case TripStatus.cancelled:
        icon = Icons.close_rounded;
        bg = const Color(0xFFFFEEEE);
        fg = const Color(0xFFEF4444);
        break;
    }
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: fg),
    );
  }

  Widget _dotLine({
    required Color dotColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 6, right: 8),
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF1b0130),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _noteBox({
    required IconData icon,
    required Color bg,
    required Color border,
    required String text,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool filled = true,
    Color? color,
    Color? bg,
    Color? textColor,
  }) {
    final Color effectiveBg =
        bg ?? (filled ? const Color(0xFFec6206) : const Color(0xFFF3F4F6));
    final Color effectiveText =
        textColor ?? (filled ? Colors.white : const Color(0xFF374151));
    final Color effectiveIcon = filled
        ? Colors.white
        : (color ?? const Color(0xFF6B7280));
    return Material(
      color: effectiveBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: effectiveIcon),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: effectiveText,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TripStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final data = _colorsAndLabel(status);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: data.$1,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        data.$3,
        style: TextStyle(
          color: data.$2,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  (Color, Color, String) _colorsAndLabel(TripStatus s) {
    switch (s) {
      case TripStatus.pending:
        return (const Color(0xFFFFF7ED), const Color(0xFF92400E), 'Pendiente');
      case TripStatus.verified:
        return (const Color(0xFFEFFDF5), const Color(0xFF065F46), 'Confirmado');
      case TripStatus.inProgress:
        return (
          const Color(0xFFEFF6FF),
          const Color(0xFF1E40AF),
          'En progreso',
        );
      case TripStatus.completed:
        return (const Color(0xFFF3F4F6), const Color(0xFF374151), 'Completado');
      case TripStatus.cancelled:
        return (const Color(0xFFFFEEEE), const Color(0xFF991B1B), 'Cancelado');
    }
  }
}
