import 'package:flutter/foundation.dart';

import 'entities.dart';

@immutable
class Building {
  const Building({
    required this.floors,
    required this.navigationGraph,
    required this.obstacles,
  });

  final List<Floor> floors;
  final Map<Position, List<Position>> navigationGraph;
  final Map<int, List<Shape>> obstacles;

  List<Room> get rooms => floors.expand((e) => e.rooms).toList();
}
