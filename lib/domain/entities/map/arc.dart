part of 'shape.dart';

@immutable
final class Arc extends Shape {
  const Arc({
    required this.origin,
    required this.radius,
    required this.startAngle,
    required this.endAngle,
  });

  factory Arc.fromJson(Map<String, dynamic> json) => Arc(
        origin: Offset(
          json['x'] as double,
          json['y'] as double,
        ),
        radius: json['r'] as double,
        startAngle: (json['startAngle'] as num) / 180.0 * pi,
        endAngle: (json['endAngle'] as num) / 180.0 * pi,
      );

  final Offset origin;
  final double radius;
  final double startAngle;
  final double endAngle;

  @override
  Path add({
    required Path path,
  }) {
    return path
      ..arcTo(
        Rect.fromCircle(
          center: origin,
          radius: radius,
        ),
        startAngle,
        endAngle - startAngle,
        true,
      );
  }

  @override
  bool isIntersecting({
    required Offset p1,
    required Offset p2,
  }) {
    final a = origin;
    final b = p1;
    final c = p2;

    final ba = Offset(b.dx - a.dx, b.dy - a.dy);
    final ca = Offset(c.dx - a.dx, c.dy - a.dy);

    final baLength = sqrt(ba.dx * ba.dx + ba.dy * ba.dy);
    final caLength = sqrt(ca.dx * ca.dx + ca.dy * ca.dy);

    final baNormalized = Offset(ba.dx / baLength, ba.dy / baLength);
    final caNormalized = Offset(ca.dx / caLength, ca.dy / caLength);

    final dot =
        baNormalized.dx * caNormalized.dx + baNormalized.dy * caNormalized.dy;
    final angle = acos(dot);

    return angle < endAngle && angle > startAngle;
  }

  @override
  List<Offset> get points {
    final points = <Offset>[];
    const step = 0.1;

    for (var i = startAngle; i < endAngle; i += step) {
      points.add(
        Offset(
          origin.dx + radius * cos(i),
          origin.dy + radius * sin(i),
        ),
      );
    }

    return points;
  }

  @override
  Offset get center {
    final x =
        origin.dx + radius * cos(startAngle + (endAngle - startAngle) / 2);
    final y =
        origin.dy + radius * sin(startAngle + (endAngle - startAngle) / 2);
    return Offset(x, y);
  }
}
