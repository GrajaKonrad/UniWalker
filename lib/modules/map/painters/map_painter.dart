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
      ..color = AppColors.secondary300
      ..strokeWidth = 1.5;

    final doorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.secondary300
      ..strokeWidth = 0.5;

    final pathPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.secondary300
      ..strokeWidth = 1;

    final graphPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.grayscale300
      ..strokeWidth = .5;

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

    for (final e in floor.graph.entries) {
      for (final n in e.value) {
        canvas.drawLine(
          e.key * scale - offset * scale,
          n * scale - offset * scale,
          Paint()
            ..strokeWidth = 0.4
            ..color = AppColors.primary100,
        );
      }

      canvas.drawCircle(
        (e.key - offset) * scale,
        2,
        Paint()..color = AppColors.primary300,
      );
    }

    for (final e in floor.triangles) {
      canvas
        ..drawLine(
          (e.a - offset) * scale,
          (e.b - offset) * scale,
          graphPaint,
        )
        ..drawLine(
          (e.b - offset) * scale,
          (e.c - offset) * scale,
          graphPaint,
        )
        ..drawLine(
          (e.c - offset) * scale,
          (e.a - offset) * scale,
          graphPaint,
        );
    }

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
