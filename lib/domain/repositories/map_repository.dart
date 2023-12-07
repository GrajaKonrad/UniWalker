import '../entities/entities.dart';

abstract interface class MapRepository {
  Future<List<MapLayer>> getMap();
}
