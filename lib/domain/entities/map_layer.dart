import 'obstacle.dart';

class MapLayer {
  const MapLayer({
    required this.floor,
    required this.obstacle,
  });

  final int floor;
  final List<Obstacle> obstacle;
}
