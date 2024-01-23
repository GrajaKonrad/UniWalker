import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

import '../../../ui/colors.dart';

class MapPainter extends CustomPainter {
  MapPainter({
    required this.walls,
    required this.doors,
    required this.image,
    required this.offset,
    required this.scale,
    this.path,
  });

  final Path walls;
  final Path doors;
  final ui.Image image;
  final Offset offset;
  final double scale;
  final List<Offset>? path;

  @override
  void paint(Canvas canvas, Size size) {
    final wallPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.primary300
      ..strokeWidth = 1;

    final doorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.secondary300
      ..strokeWidth = 0.5;

    final pathPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.secondary300
      ..strokeWidth = 1;

    canvas
      ..drawPath(
        walls.transform(
          // Matrix4.identity().storage,
          Matrix4.compose(
            Vector3(-offset.dx, -offset.dy, 0) * scale,
            Quaternion.identity(),
            Vector3(scale, scale, 1),
          ).storage,
        ),
        wallPaint,
      )
      ..drawPath(
        doors.transform(
          // Matrix4.identity().storage,
          Matrix4.compose(
            Vector3(-offset.dx, -offset.dy, 0) * scale,
            Quaternion.identity(),
            Vector3(scale, scale, 1),
          ).storage,
        ),
        doorPaint,
      );

    if (path?.isNotEmpty ?? false) {
      canvas
        ..drawCircle(
          path!.first * scale - offset * scale,
          4,
          pathPaint,
        )
        ..drawCircle(
          path!.last * scale - offset * scale,
          4,
          pathPaint,
        );

      for (var i = 0; i < path!.length - 1; i++) {
        canvas.drawLine(
          path![i] * scale - offset * scale,
          path![i + 1] * scale - offset * scale,
          pathPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) => false;
}
