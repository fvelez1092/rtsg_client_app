import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:app_rtsg_client/application/trips_controller.dart';
import 'package:app_rtsg_client/core/theme/app_colors.dart';
import 'package:app_rtsg_client/data/models/trips/trip_model.dart';

class ActivityPage extends GetView<TripsController> {
  const ActivityPage({super.key});

  String _statusLabel(TripStatus status) {
    switch (status) {
      case TripStatus.pending:
        return 'Pendiente';
      case TripStatus.verified:
        return 'Verificado';
      case TripStatus.inProgress:
        return 'En progreso';
      case TripStatus.completed:
        return 'Completado';
      case TripStatus.cancelled:
        return 'Cancelado';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final trips = controller.trips;
      final totalDistance = trips.fold<double>(
        0,
        (sum, trip) => sum + trip.distanceKm.toDouble(),
      );
      final totalSpent = trips.fold<double>(
        0,
        (sum, trip) => sum + trip.cost.toDouble(),
      );

      return SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.fetchTrips,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                child: Row(
                  children: [
                    Expanded(
                      child: _Stat(
                        label: 'Viajes',
                        value: trips.length.toString(),
                      ),
                    ),
                    const SizedBox(
                      height: 42,
                      child: VerticalDivider(color: AppColors.borderSoft),
                    ),
                    Expanded(
                      child: _Stat(
                        label: 'Distancia',
                        value: '${totalDistance.toStringAsFixed(1)} km',
                      ),
                    ),
                    const SizedBox(
                      height: 42,
                      child: VerticalDivider(color: AppColors.borderSoft),
                    ),
                    Expanded(
                      child: _Stat(
                        label: 'Gastado',
                        value: '\$${totalSpent.toStringAsFixed(2)}',
                      ),
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
              if (controller.loading.value && trips.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (controller.error.value.isNotEmpty && trips.isEmpty)
                _ErrorState(
                  message: controller.error.value,
                  onRetry: controller.fetchTrips,
                )
              else if (trips.isEmpty)
                const _EmptyState()
              else
                ...trips.map(
                  (trip) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TripCard(
                      trip: trip,
                      statusLabel: _statusLabel(trip.status),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
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
          textAlign: TextAlign.center,
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
  const _TripCard({required this.trip, required this.statusLabel});

  final Trip trip;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final statusColor = Trip.leftBorder(trip.status);
    final date = DateFormat('dd MMM · HH:mm', 'es').format(trip.requestedDate);

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
              Expanded(
                child: Text(
                  date,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _PointRow(color: AppColors.brandGreen, text: trip.departureAddress),
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
          _PointRow(color: AppColors.brandRed, text: trip.destinationAddress),
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
                '${trip.distanceKm.toStringAsFixed(1)} km',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                Trip.priceLabel(trip),
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
            text.isEmpty ? 'Dirección no disponible' : text,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 42,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 12),
          Text(
            'Todavía no tienes viajes registrados.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 38,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 10),
          const Text(
            'No pudimos cargar tu actividad.',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
