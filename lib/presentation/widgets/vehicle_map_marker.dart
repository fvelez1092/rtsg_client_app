import 'package:flutter/material.dart';

/// A north-facing vehicle drawn as vectors so it stays sharp at every density.
class VehicleMapMarker extends StatelessWidget {
  const VehicleMapMarker({super.key, this.turns = 0});
  final double turns;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Vehículo del conductor',
    image: true,
    child: AnimatedRotation(
      turns: turns,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
      child: const SizedBox(
        width: 48,
        height: 48,
        child: CustomPaint(painter: _VehiclePainter()),
      ),
    ),
  );
}

class _VehiclePainter extends CustomPainter {
  const _VehiclePainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 48, size.height / 48);
    final paint = Paint()..isAntiAlias = true;
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(12, 3, 24, 42),
      const Radius.circular(8),
    );
    canvas.drawShadow(
      Path()..addRRect(body),
      Colors.black.withValues(alpha: .5),
      4,
      true,
    );
    paint.color = const Color(0xFF263238);
    for (final y in [11.0, 31.0]) {
      for (final x in [9.0, 33.0]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, 6, 9),
            const Radius.circular(2),
          ),
          paint,
        );
      }
    }
    paint.color = Colors.white;
    canvas.drawRRect(body, paint);
    paint
      ..color = const Color(0xFF8A9BA3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(body, paint);
    paint
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF294B5B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(15, 12, 18, 23),
        const Radius.circular(5),
      ),
      paint,
    );
    paint.color = const Color(0xFFB8DCE7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(16, 13, 16, 7),
        const Radius.circular(2),
      ),
      paint,
    );
    paint.color = const Color(0xFFF2F5F6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(17, 22, 14, 10),
        const Radius.circular(3),
      ),
      paint,
    );
    paint.color = const Color(0xFFFFE6A0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(14, 6, 5, 3),
        const Radius.circular(1),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(29, 6, 5, 3),
        const Radius.circular(1),
      ),
      paint,
    );
    paint.color = const Color(0xFFDE5353);
    canvas.drawRect(const Rect.fromLTWH(14, 39, 4, 3), paint);
    canvas.drawRect(const Rect.fromLTWH(30, 39, 4, 3), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _VehiclePainter oldDelegate) => false;
}
