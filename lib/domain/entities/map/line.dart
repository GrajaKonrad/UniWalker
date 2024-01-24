part of 'map_element.dart';

final class Line extends MapElement {
  Line({
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
  Path addWithPadding({
    required Path path,
    required double padding,
  }) {
    final diff = p1 - p2;
    final normalized = diff / diff.distance;
    final offset = Offset(normalized.dy, -normalized.dx) * padding;

    return path
      ..moveTo(
        p1.dx + offset.dx,
        p1.dy + offset.dy,
      )
      ..lineTo(
        p2.dx + offset.dx,
        p2.dy + offset.dy,
      )
      ..lineTo(
        p2.dx - offset.dx,
        p2.dy - offset.dy,
      )
      ..lineTo(
        p1.dx - offset.dx,
        p1.dy - offset.dy,
      )
      ..close();
  }
}
