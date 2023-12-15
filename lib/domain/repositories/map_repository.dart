// ignore_for_file: one_member_abstracts

import '../entities/entities.dart';

abstract interface class MapRepository {
  Future<List<MapLayer>> getMap();
}
