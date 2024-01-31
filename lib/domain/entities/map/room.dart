import 'package:flutter/foundation.dart';

@immutable
class Room {
  const Room({
    required this.x,
    required this.y,
    required this.name,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      x: json['x'] as double,
      y: json['y'] as double,
      name: json['name'] as String,
    );
  }

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
