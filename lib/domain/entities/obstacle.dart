import 'package:flutter/services.dart';

class Obstacle {
  const Obstacle({
    required this.vertices,
  });

  final List<Offset> vertices;
}
