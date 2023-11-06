import 'package:flutter/material.dart';

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0.5 * size.width, 0)
      ..lineTo(size.width, 0.5 * size.height)
      ..lineTo(0.75 * size.width, 0.5 * size.height)
      ..lineTo(0.75 * size.width, size.height)
      ..lineTo(0.25 * size.width, size.height)
      ..lineTo(0.25 * size.width, 0.5 * size.height)
      ..lineTo(0, 0.5 * size.height)
      ..close();

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blue;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ArrowPainter oldDelegate) => false;
}
