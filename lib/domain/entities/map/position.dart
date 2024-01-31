import 'package:meta/meta.dart';

@immutable
class Position {
  const Position({
    required this.x,
    required this.y,
    required this.floor,
  });

  final double x;
  final double y;
  final int floor;

  @override
  bool operator ==(Object other) {
    return other is Position &&
        other.x == x &&
        other.y == y &&
        other.floor == floor;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ floor.hashCode;
}
