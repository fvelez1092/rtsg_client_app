import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_rtsg_client/core/theme/app_colors.dart';
import 'package:app_rtsg_client/routes/rtsg_routes.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  late DateTime _selectedDate;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  final List<TimeOfDay> _quickTimes = const [
    TimeOfDay(hour: 8, minute: 0),
    TimeOfDay(hour: 10, minute: 30),
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 18, minute: 30),
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day).add(
      const Duration(days: 1),
    );
  }

  String _dateLabel(DateTime date) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  Future<void> _pickCustomTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (result != null && mounted) {
      setState(() => _selectedTime = result);
    }
  }

  void _continueToTrip() {
    final label = '${_dateLabel(_selectedDate)} · ${_selectedTime.format(context)}';

    Get.toNamed(
      AppRoutes.TRIP,
      arguments: {
        'isReservation': true,
        'reservationDate': _selectedDate.toIso8601String(),
        'reservationTime': '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
        'reservationLabel': label,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reservar viaje'),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(
              '¿Cuándo quieres viajar?',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Primero selecciona la fecha y hora. Después podrás elegir el punto de partida y destino como en un viaje normal.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 60)),
                onDateChanged: (date) {
                  setState(() => _selectedDate = date);
                },
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Hora de recogida',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ..._quickTimes.map((time) {
                  final selected = time.hour == _selectedTime.hour &&
                      time.minute == _selectedTime.minute;

                  return ChoiceChip(
                    selected: selected,
                    label: Text(time.format(context)),
                    onSelected: (_) => setState(() => _selectedTime = time),
                    selectedColor: colors.primary.withValues(alpha: 0.16),
                    backgroundColor: AppColors.surface,
                    side: BorderSide(
                      color: selected ? colors.primary : AppColors.borderSoft,
                    ),
                    labelStyle: TextStyle(
                      color: selected ? colors.primary : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }),
                ActionChip(
                  avatar: const Icon(Icons.schedule_rounded, size: 18),
                  label: const Text('Otra hora'),
                  onPressed: _pickCustomTime,
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.borderSoft),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.brandGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.event_available_rounded,
                      color: AppColors.brandGreen,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tu reserva',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${_dateLabel(_selectedDate)} · ${_selectedTime.format(context)}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: _continueToTrip,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Continuar a seleccionar ruta'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandGreen,
                  foregroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
