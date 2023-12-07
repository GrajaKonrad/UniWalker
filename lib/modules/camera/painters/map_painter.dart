import 'package:flutter/material.dart';

import '../../../domain/entities/map_layer.dart';

class MapPainter extends CustomPainter {
  const MapPainter({
    required this.layer,
  });

  final MapLayer layer;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 1;

    for (final obstacle in layer.obstacles) {
      final x1 = _inverseLerp(
        layer.boundries.left,
        layer.boundries.right,
        obstacle.a.dx,
      );
      final y1 = _inverseLerp(
        layer.boundries.top,
        layer.boundries.bottom,
        obstacle.a.dy,
      );
      final x2 = _inverseLerp(
        layer.boundries.left,
        layer.boundries.right,
        obstacle.b.dx,
      );
      final y2 = _inverseLerp(
        layer.boundries.top,
        layer.boundries.bottom,
        obstacle.b.dy,
      );
      canvas.drawLine(
        Offset(x1 * size.width, (1 - y1) * size.height),
        Offset(x2 * size.width, (1 - y2) * size.height),
        paint,
      );
    }
  }

  double _inverseLerp(double a, double b, double v) {
    return (v - a) / (b - a);
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) => true;
}
