import 'package:flutter/services.dart';

import 'map_element.dart';

class MapLayer {
  MapLayer({
    required this.walls,
  }) {
    var minX = double.maxFinite;
    var minY = double.maxFinite;
    var maxX = -double.maxFinite;
    var maxY = -double.maxFinite;

    for (final wall in walls) {
      if (wall.constraints.left < minX) {
        minX = wall.constraints.left;
      }
      if (wall.constraints.right > maxX) {
        maxX = wall.constraints.right;
      }
      if (wall.constraints.top < minY) {
        minY = wall.constraints.top;
      }
      if (wall.constraints.bottom > maxY) {
        maxY = wall.constraints.bottom;
      }
    }
    constraints = Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  final List<MapElemnent> walls;
  late final Rect constraints;
}
