import 'dart:ui';

class MapLayer {
  MapLayer({
    required this.walls,
    required this.doors,
    required this.blocked,
    required this.map,
  });

  final Path walls;
  final Path doors;
  final Path blocked;

  final Image map;
}
