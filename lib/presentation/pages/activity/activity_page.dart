import 'package:flutter/material.dart';

import 'package:app_rtsg_client/core/theme/app_colors.dart';
import 'package:app_rtsg_client/presentation/widgets/main_bottom_navigation.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  static const _trips = [
    _MockTrip(
      date: 'Hoy · 09:42',
      origin: 'La Carolina',
      destination: 'Centro Histórico',
      price: r'$4.80',
      distance: '6.8 km',
      status: 'Completado',
    ),
    _MockTrip(
      date: '3 sep · 18:15',
      origin: 'Iñaquito',
      destination: 'Cumbayá',
      price: r'$7.25',
      distance: '12.3 km',
      status: 'Completado',
    ),
    _MockTrip(
      date: '30 ago · 12:20',
      origin: 'El Batán',
      destination: 'Aeropuerto Mariscal Sucre',
      price: r'$18.40',
      distance: '34.1 km',
      status: 'Completado',
    ),
    _MockTrip(
      date: '27 ago · 08:05',
      origin: 'Plaza Foch',
      destination: 'Universidad Central',
      price: r'$3.60',
      distance: '5.2 km',
      status: 'Completado',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
          children: [
            Text(
              'Tu actividad',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Historial de viajes realizados con RTSG.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: _Stat(label: 'Viajes', value: '12'),
                  ),
                  SizedBox(
                    height: 42,
                    child: VerticalDivider(color: AppColors.borderSoft),
                  ),
                  Expanded(
                    child: _Stat(label: 'Distancia', value: '126 km'),
                  ),
                  SizedBox(
                    height: 42,
                    child: VerticalDivider(color: AppColors.borderSoft),
                  ),
                  Expanded(
                    child: _Stat(label: 'Gastado', value: r'$86.35'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Viajes recientes',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            ..._trips.map(
              (trip) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TripCard(trip: trip),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 1),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip});

  final _MockTrip trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                trip.date,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.brandGreen.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  trip.status,
                  style: const TextStyle(
                    color: AppColors.brandGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _PointRow(
            color: AppColors.brandGreen,
            text: trip.origin,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 18,
                child: VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: AppColors.borderSoft,
                ),
              ),
            ),
          ),
          _PointRow(
            color: AppColors.brandRed,
            text: trip.destination,
          ),
          const SizedBox(height: 15),
          const Divider(height: 1, color: AppColors.borderSoft),
          const SizedBox(height: 13),
          Row(
            children: [
              const Icon(
                Icons.route_outlined,
                size: 17,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                trip.distance,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                trip.price,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PointRow extends StatelessWidget {
  const _PointRow({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _MockTrip {
  const _MockTrip({
    required this.date,
    required this.origin,
    required this.destination,
    required this.price,
    required this.distance,
    required this.status,
  });

  final String date;
  final String origin;
  final String destination;
  final String price;
  final String distance;
  final String status;
}
