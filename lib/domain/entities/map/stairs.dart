import 'package:meta/meta.dart';

@immutable
class Stairs {
  const Stairs({
    required this.x,
    required this.y,
    required this.targetFloor,
  });

  final double x;
  final double y;
  final int targetFloor;
}
