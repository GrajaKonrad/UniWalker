import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../ui/colors.dart';

class TestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const p1 = Offset(10, 10);
    final p2 = Offset(size.width - 10, size.height - 10);
    final padding = _padding(p1, p2) * 5;

    final path = Path()
      ..moveTo(p1.dx + padding.dx, p1.dy + padding.dy)
      ..lineTo(p2.dx + padding.dx, p2.dy + padding.dy)
      ..lineTo(p2.dx - padding.dx, p2.dy - padding.dy)
      ..lineTo(p1.dx - padding.dx, p1.dy - padding.dy)
      ..close();
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.black
      ..shader = ui.Gradient.linear(
        (p1 + p2) / 2 - padding,
        (p1 + p2) / 2 + padding,
        [
          Colors.transparent,
          const Color(0xffff0000),
          Colors.transparent,
        ],
        [
          0.0,
          0.5,
          1.0,
        ],
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  Offset _padding(Offset a, Offset b) {
    final diff = a - b;
    final tmp = diff / diff.distance;
    return Offset(tmp.dy, -tmp.dx);
  }
}
