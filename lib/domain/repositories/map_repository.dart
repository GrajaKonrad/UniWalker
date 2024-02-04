import '../entities/entities.dart';

abstract interface class MapRepository {
  Future<Building> getMap();

  Future<List<Position>> findPath({
    required Building building,
    required Position start,
    required Position end,
  });
}
