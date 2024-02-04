import 'dart:ui';

import 'package:meta/meta.dart';

import 'entities.dart';

@immutable
class Floor {
  const Floor({
    required this.level,
    required this.walls,
    required this.doors,
    required this.rooms,
  });

  final int level;
  final Path walls;
  final Path doors;
  final List<Room> rooms;
}
