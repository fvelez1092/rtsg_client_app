import 'package:flutter/material.dart';

class TripMetrics extends StatelessWidget {
  final double? distanceKm;
  final double? fare;
  const TripMetrics({super.key, this.distanceKm, this.fare});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _metric(
            context,
            'Distancia',
            distanceKm == null
                ? 'Por confirmar'
                : '${distanceKm!.toStringAsFixed(2)} km',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _metric(
            context,
            'Costo',
            fare == null ? 'Por confirmar' : '\$${fare!.toStringAsFixed(2)}',
          ),
        ),
      ],
    );
  }

  Widget _metric(BuildContext context, String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 4),
      Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    ],
  );
}
