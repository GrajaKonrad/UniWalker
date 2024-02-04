import 'package:meta/meta.dart';

@immutable
class Position {
  const Position({
    required this.x,
    required this.y,
    required this.level,
  });

  final double x;
  final double y;
  final int level;

  @override
  bool operator ==(Object other) {
    return other is Position &&
        other.x == x &&
        other.y == y &&
        other.level == level;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ level.hashCode;
}
