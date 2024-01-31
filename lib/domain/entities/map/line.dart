part of 'shape.dart';

@immutable
final class Line extends Shape {
  const Line({
    required this.p1,
    required this.p2,
  });

  factory Line.fromJson(Map<String, dynamic> json) => Line(
        p1: Offset(
          json['x1'] as double,
          json['y1'] as double,
        ),
        p2: Offset(
          json['x2'] as double,
          json['y2'] as double,
        ),
      );

  final Offset p1;
  final Offset p2;

  @override
  Path add({
    required Path path,
  }) {
    return path
      ..moveTo(
        p1.dx,
        p1.dy,
      )
      ..lineTo(
        p2.dx,
        p2.dy,
      );
  }

  @override
  bool isIntersecting({
    required Offset p1,
    required Offset p2,
  }) {
    final a = this.p1;
    final b = this.p2;
    final c = p1;
    final d = p2;

    final det = (b.dx - a.dx) * (d.dy - c.dy) - (d.dx - c.dx) * (b.dy - a.dy);
    if (det == 0) {
      return false;
    }

    final lambda =
        ((d.dy - c.dy) * (d.dx - a.dx) + (c.dx - d.dx) * (d.dy - a.dy)) / det;
    final gamma =
        ((a.dy - b.dy) * (d.dx - a.dx) + (b.dx - a.dx) * (d.dy - a.dy)) / det;

    return (0 < lambda && lambda < 1) && (0 < gamma && gamma < 1);
  }

  @override
  List<Offset> get points => [p1, p2];

  @override
  (Offset, Offset) get centerPoints {
    final dx = (p1.dx + p2.dx) / 2;
    final dy = (p1.dy + p2.dy) / 2;
    final angle = atan2(p2.dy - p1.dy, p2.dx - p1.dx);
    final closerPoint = Offset(
      dx + Shape.doorPointsOffset * cos(angle + pi / 2),
      dy + Shape.doorPointsOffset * sin(angle + pi / 2),
    );
    final fartherPoint = Offset(
      dx + Shape.doorPointsOffset * cos(angle - pi / 2),
      dy + Shape.doorPointsOffset * sin(angle - pi / 2),
    );
    return (closerPoint, fartherPoint);
  }
}
