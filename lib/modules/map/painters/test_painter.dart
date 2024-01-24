import 'dart:typed_data';

import 'package:delaunay/delaunay.dart';
import 'package:flutter/material.dart';

import '../../../ui/colors.dart';

class TestPainter extends CustomPainter {
  TestPainter({
    required this.points,
  });

  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size size) {
    final rawPoints = Float32List(points.length * 2);
    for (var i = 0; i < points.length; i++) {
      rawPoints[i * 2] = points[i].dx;
      rawPoints[i * 2 + 1] = points[i].dy;
    }

    final triangulation = Delaunay(rawPoints)..update();

    for (var i = 0; i < triangulation.triangles.length; i += 3) {
      final a = triangulation.triangles[i];
      final b = triangulation.triangles[i + 1];
      final c = triangulation.triangles[i + 2];

      final path = Path()
        ..moveTo(triangulation.coords[2 * a], triangulation.coords[2 * a + 1])
        ..lineTo(triangulation.coords[2 * b], triangulation.coords[2 * b + 1])
        ..lineTo(triangulation.coords[2 * c], triangulation.coords[2 * c + 1])
        ..close();

      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.primary100
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    for (final point in points) {
      canvas.drawCircle(point, 3, Paint()..color = AppColors.secondary400);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
