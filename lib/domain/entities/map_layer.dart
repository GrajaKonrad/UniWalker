import 'package:flutter/services.dart';

import 'obstacle.dart';

class MapLayer {
  MapLayer({
    required this.obstacles,
  }) {
    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = double.negativeInfinity;
    var maxY = double.negativeInfinity;

    for (final obstacle in obstacles) {
      if (obstacle.a.dx < minX) {
        minX = obstacle.a.dx;
      }
      if (obstacle.a.dx > maxX) {
        maxX = obstacle.a.dx;
      }
      if (obstacle.a.dy < minY) {
        minY = obstacle.a.dy;
      }
      if (obstacle.a.dy > maxY) {
        maxY = obstacle.a.dy;
      }

      if (obstacle.b.dx < minX) {
        minX = obstacle.b.dx;
      }
      if (obstacle.b.dx > maxX) {
        maxX = obstacle.b.dx;
      }
      if (obstacle.b.dy < minY) {
        minY = obstacle.b.dy;
      }
      if (obstacle.b.dy > maxY) {
        maxY = obstacle.b.dy;
      }
    }
    boundries = Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  final List<Obstacle> obstacles;
  late final Rect boundries;
}
