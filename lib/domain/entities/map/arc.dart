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

  static const _resolution = 0.01;
  static const _default = 4;

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
    // Translate the line and circle so that the circle's center is at the origin
    final p1t = p1 - origin;
    final p2t = p2 - origin;

    // Compute the line's direction vector
    final d = p2t - p1t;

    // Compute the coefficients of the quadratic equation
    final a = d.dx * d.dx + d.dy * d.dy;
    final b = 2 * (p1t.dx * d.dx + p1t.dy * d.dy);
    final c = p1t.dx * p1t.dx + p1t.dy * p1t.dy - radius * radius;

    // Compute the discriminant
    final disc = b * b - 4 * a * c;

    // If the discriminant is negative, the line does not intersect the circle
    if (disc < 0) {
      return false;
    }

    // Compute the two solutions of the quadratic equation
    final t1 = (-b - sqrt(disc)) / (2 * a);
    final t2 = (-b + sqrt(disc)) / (2 * a);

    // Check if the intersection points are within the arc's angles
    bool checkAngle(Offset p) {
      var angle = atan2(p.dy, p.dx);
      if (angle < 0) {
        angle += 2 * pi;
      }

      if (startAngle < endAngle) {
        return startAngle <= angle && angle <= endAngle;
      } else {
        return startAngle >= angle || angle >= endAngle;
      }
    }

    // If either of the intersection points is within the line segment and the arc's angles, return true
    if (0 <= t1 && t1 <= 1 && checkAngle(p1t + d * t1)) {
      return true;
    }
    if (0 <= t2 && t2 <= 1 && checkAngle(p1t + d * t2)) {
      return true;
    }

    // Otherwise, the line does not intersect the arc
    return false;
  }

  @override
  List<Offset> get points {
    final points = <Offset>[];

    var angle = endAngle - startAngle;
    if (angle < 0) {
      angle += 2 * pi;
    }

    final target = (_default + _resolution * radius) * angle / (2 * pi);
    if (target == 0) {
      return points;
    }

    final step = 1 / target;

    print('angle: $angle, step: $step');

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
  (Offset, Offset) get centerPoints {
    final angle = startAngle + (endAngle - startAngle) / 2;
    final closerPoint = Offset(
      origin.dx + (radius - Shape.doorPointsOffset) * cos(angle),
      origin.dy + (radius - Shape.doorPointsOffset) * sin(angle),
    );
    final fartherPoint = Offset(
      origin.dx + (radius + Shape.doorPointsOffset) * cos(angle),
      origin.dy + (radius + Shape.doorPointsOffset) * sin(angle),
    );
    return (closerPoint, fartherPoint);
  }
}
