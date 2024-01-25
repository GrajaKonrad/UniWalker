// ignore_for_file: one_member_abstracts

import 'dart:ui';

import '../entities/entities.dart';

abstract interface class MapRepository {
  Future<List<Floor>> getMap();

  Future<List<Offset>> findPath({
    required Floor layer,
    required Offset start,
    required Offset end,
  });
}
