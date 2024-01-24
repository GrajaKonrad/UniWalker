import 'dart:math';
import 'dart:ui';

import 'package:meta/meta.dart';

@immutable
class Triangle {
  Triangle({
    required this.a,
    required this.b,
    required this.c,
  }) : midPoint = _calculateIncenter(a, b, c);

  final Offset a;
  final Offset b;
  final Offset c;

  final Offset midPoint;

  static Offset _calculateIncenter(Offset a, Offset b, Offset c) {
    final ab = _distance(a, b);
    final bc = _distance(b, c);
    final ca = _distance(c, a);

    final x = (bc * a.dx + ca * b.dx + ab * c.dx) / (ab + bc + ca);
    final y = (bc * a.dy + ca * b.dy + ab * c.dy) / (ab + bc + ca);

    return Offset(x, y);
  }

  static double _distance(Offset a, Offset b) {
    final x = a.dx - b.dx;
    final y = a.dy - b.dy;
    return sqrt(x * x + y * y);
  }
}
