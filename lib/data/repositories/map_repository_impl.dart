import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/entities.dart';
import '../../domain/repositories/map_repository.dart';

class MapRepositoryImpl implements MapRepository {
  @override
  Future<List<MapLayer>> getMap() async {
    final csv = const CsvToListConverter(fieldDelimiter: ';')
        .convert(await rootBundle.loadString('assets/sciany1.csv'));

    final walls = <Obstacle>[];
    for (var i = 1; i < csv.length; i++) {
      final line = csv[i];
      walls.add(
        Obstacle(
          a: Offset(
            double.parse(line[1].toString()) / 100,
            double.parse(line[2].toString()) / 100,
          ),
          b: Offset(
            double.parse(line[4].toString()) / 100,
            double.parse(line[5].toString()) / 100,
          ),
        ),
      );
    }
    return [MapLayer(obstacles: walls)];
  }
}
