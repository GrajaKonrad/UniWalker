import 'dart:math';
import 'dart:ui';

import 'package:meta/meta.dart';

@immutable
class Triangle {
  const Triangle({
    required this.a,
    required this.b,
    required this.c,
  });

  final Offset a;
  final Offset b;
  final Offset c;

  Offset get inscribedCircleCenter {
    final ab = _distance(a, b);
    final bc = _distance(b, c);
    final ca = _distance(c, a);

    final p = ab + bc + ca;

    return Offset(
      (a.dx * bc + b.dx * ca + c.dx * ab) / p,
      (a.dy * bc + b.dy * ca + c.dy * ab) / p,
    );
  }

  double get area {
    final ab = _distance(a, b);
    final bc = _distance(b, c);
    final ca = _distance(c, a);

    final s = (ab + bc + ca) / 2;

    return sqrt(s * (s - ab) * (s - bc) * (s - ca));
  }

  bool isPointInside(Offset point) {
    final d1 = _sign(point, a, b);
    final d2 = _sign(point, b, c);
    final d3 = _sign(point, c, a);

    final hasNeg = (d1 < 0) || (d2 < 0) || (d3 < 0);
    final hasPos = (d1 > 0) || (d2 > 0) || (d3 > 0);

    return !(hasNeg && hasPos);
  }

  static double _distance(Offset a, Offset b) {
    final x = a.dx - b.dx;
    final y = a.dy - b.dy;
    return sqrt(x * x + y * y);
  }

  double _sign(Offset p1, Offset p2, Offset p3) {
    return (p1.dx - p3.dx) * (p2.dy - p3.dy) -
        (p2.dx - p3.dx) * (p1.dy - p3.dy);
  }
}
