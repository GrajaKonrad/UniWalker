import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

import '../../../domain/entities/map/entities.dart';
import '../../../ui/colors.dart';

class MapPainter extends CustomPainter {
  MapPainter({
    required this.floor,
    required this.offset,
    required this.scale,
    this.path,
  });

  final Floor floor;
  final Offset offset;
  final double scale;
  final List<Position>? path;

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
        floor.walls.transform(
          Matrix4.compose(
            Vector3(-offset.dx, -offset.dy, 0) * scale,
            Quaternion.identity(),
            Vector3(scale, scale, 1),
          ).storage,
        ),
        wallPaint,
      )
      ..drawPath(
        floor.doors.transform(
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
        if (path![i + 1].level != floor.level) {
          continue;
        }

        canvas.drawLine(
          Offset(path![i].x, path![i].y) * scale - offset * scale,
          Offset(path![i + 1].x, path![i + 1].y) * scale - offset * scale,
          pathPaint,
        );
      }

      if (path?.first.level == floor.level) {
        canvas.drawCircle(
          Offset(path!.first.x, path!.first.y) * scale - offset * scale,
          3,
          Paint()
            ..style = PaintingStyle.fill
            ..color = AppColors.primary600,
        );
      }

      if (path?.last.level == floor.level) {
        canvas.drawCircle(
          Offset(path!.last.x, path!.last.y) * scale - offset * scale,
          6,
          Paint()
            ..style = PaintingStyle.fill
            ..color = AppColors.secondary700,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) => false;
}
