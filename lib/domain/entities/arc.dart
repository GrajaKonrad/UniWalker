part of 'map_element.dart';

final class Arc extends MapElement {
  const Arc({
    required this.center,
    required this.radius,
    required this.startAngle,
    required this.endAngle,
  });

  factory Arc.fromJson(Map<String, dynamic> json) => Arc(
        center: Offset(
          json['x'] as double,
          json['y'] as double,
        ),
        radius: json['r'] as double,
        startAngle: (json['startAngle'] as num) / 180.0 * pi,
        endAngle: (json['endAngle'] as num) / 180.0 * pi,
      );

  final Offset center;
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
          center: center,
          radius: radius,
        ),
        startAngle,
        endAngle - startAngle,
        true,
      );
  }

  @override
  Path addWithPadding({
    required Path path,
    required double padding,
  }) {
    return path
      ..arcTo(
        Rect.fromCircle(
          center: center,
          radius: radius + padding,
        ),
        startAngle,
        endAngle - startAngle,
        true,
      )
      ..arcTo(
        Rect.fromCircle(
          center: center,
          radius: radius - padding,
        ),
        endAngle,
        startAngle - endAngle,
        false,
      )
      ..close();
  }
}
