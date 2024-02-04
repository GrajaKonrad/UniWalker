import 'package:flutter/foundation.dart';

@immutable
class Room {
  const Room({
    required this.x,
    required this.y,
    required this.name,
  });

  final double x;
  final double y;
  final String name;

  @override
  bool operator ==(Object other) {
    return other is Room && other.name == name && other.x == x && other.y == y;
  }

  @override
  int get hashCode => name.hashCode;
}
