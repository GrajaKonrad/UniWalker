import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

import '../../../domain/entities/map/floor.dart';
import '../../../ui/colors.dart';

class MapPainter extends CustomPainter {
  MapPainter({
    required this.walls,
    required this.doors,
    required this.floor,
    required this.offset,
    required this.scale,
    this.path,
  });

  final Path walls;
  final Path doors;
  final Floor floor;
  final Offset offset;
  final double scale;
  final List<Offset>? path;

  @override
  void paint(Canvas canvas, Size size) {
    final wallPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.secondary400
      ..strokeWidth = 1.0;

    final doorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.primary100
      ..strokeWidth = 0.5;

    final pathPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.primary600
      ..strokeWidth = 1.5;

    canvas
      ..drawPath(
        walls.transform(
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
          Matrix4.compose(
            Vector3(-offset.dx, -offset.dy, 0) * scale,
            Quaternion.identity(),
            Vector3(scale, scale, 1),
          ).storage,
        ),
        doorPaint,
      );

    if (path?.isNotEmpty ?? false) {
      for (var i = 0; i < path!.length - 1; i++) {
        canvas.drawLine(
          path![i] * scale - offset * scale,
          path![i + 1] * scale - offset * scale,
          pathPaint,
        );
      }
      canvas
        ..drawCircle(
          path!.first * scale - offset * scale,
          3,
          Paint()
            ..style = PaintingStyle.fill
            ..color = AppColors.primary600,
        )
        ..drawCircle(
          path!.last * scale - offset * scale,
          6,
          Paint()
            ..style = PaintingStyle.fill
            ..color = AppColors.secondary700,
        );
    }
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) => false;
}
