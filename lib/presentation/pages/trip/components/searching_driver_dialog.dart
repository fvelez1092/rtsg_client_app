import 'package:flutter/material.dart';

import 'package:app_rtsg_client/core/theme/app_colors.dart';

class SearchingDriverDialog extends StatefulWidget {
  final VoidCallback onCancel;

  const SearchingDriverDialog({super.key, required this.onCancel});

  @override
  State<SearchingDriverDialog> createState() => _SearchingDriverDialogState();
}

class _SearchingDriverDialogState extends State<SearchingDriverDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (_, child) => SizedBox(
                width: 150,
                height: 150,
                child: CustomPaint(
                  painter: _SearchingPainter(progress: _controller.value),
                  child: child,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.local_taxi_rounded,
                  size: 42,
                  color: AppColors.brandGreen,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Buscando una unidad',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Estamos buscando el conductor más cercano para ti.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 22),
            TextButton(
              onPressed: widget.onCancel,
              child: const Text('Cancelar solicitud'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchingPainter extends CustomPainter {
  final double progress;

  const _SearchingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 12;

    for (var i = 0; i < 3; i++) {
      final phase = (progress + i / 3) % 1;
      final currentRadius = radius * (0.42 + phase * 0.58);
      final opacity = (1 - phase) * 0.25;
      canvas.drawCircle(
        center,
        currentRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..color = AppColors.brandGreen.withOpacity(opacity),
      );
    }

    canvas.drawCircle(
      center,
      32,
      Paint()..color = AppColors.brandGreen.withOpacity(.10),
    );
  }

  @override
  bool shouldRepaint(covariant _SearchingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
