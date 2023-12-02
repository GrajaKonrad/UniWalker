import 'package:flutter/material.dart';

import '../../../domain/entities/map_layer.dart';

class MapPainter extends CustomPainter {
  const MapPainter({
    required this.layer,
  });

  final MapLayer layer;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.green;

    for (var obstacle in layer.obstacle) {
      final path = Path()
        ..moveTo(obstacle.vertices.first.dx, obstacle.vertices.first.dy);

      for (var vertex in obstacle.vertices) {
        path.lineTo(vertex.dx, vertex.dy);
      }

      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) => true;
}
