import 'dart:math';

import 'package:meta/meta.dart';

@immutable
class Point {
  const Point({
    required this.x,
    required this.y,
  });

  final int x;
  final int y;

  Point operator -(Point other) => Point(
        x: x - other.x,
        y: y - other.y,
      );

  @override
  bool operator ==(Object other) =>
      other is Point && x == other.x && y == other.y;

  double get distance => sqrt(x * x + y * y);

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}
