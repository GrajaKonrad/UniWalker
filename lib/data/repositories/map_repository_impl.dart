import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';

import '../../domain/entities/entities.dart';
import '../../domain/entities/map_element.dart';
import '../../domain/repositories/map_repository.dart';

class MapRepositoryImpl implements MapRepository {
  @override
  Future<List<MapLayer>> getMap() async {
    final json = (jsonDecode(await rootBundle.loadString('assets/map.json'))
        as List<dynamic>)[0] as Map<String, dynamic>;

    final walls = Path();
    final blocked = Path();
    for (final wall in json['walls'] as List<dynamic>) {
      MapElement.fromJson(wall as Map<String, dynamic>)
        ..add(path: walls)
        ..addWithPadding(path: blocked, padding: 50);
    }

    var doors = Path();
    for (final door in json['doors'] as List<dynamic>) {
      doors =
          MapElement.fromJson(door as Map<String, dynamic>).add(path: doors);
    }

    return [
      MapLayer(
        walls: walls,
        blocked: blocked,
        doors: doors,
        map: await _generateMap(blocked: blocked),
      ),
    ];
  }

  @override
  Future<List<Offset>> findPath({
    required MapLayer layer,
    required Offset start,
    required Offset end,
  }) async {
    final startCoordinates = _getCoordinates(layer: layer, offset: start);
    final endCoordinates = _getCoordinates(layer: layer, offset: end);

    print(startCoordinates);
    print(endCoordinates);
    print('(${layer.map.width}, ${layer.map.height})');

    return Future.value([]);
  }

  Future<Image> _generateMap({
    required Path blocked,
  }) {
    final bounds = blocked.getBounds();
    final recorder = PictureRecorder();

    Canvas(recorder)
      ..drawPaint(
        Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0xffffffff),
      )
      ..drawPath(
        blocked.transform(
          (Matrix4.identity()
                ..scale(0.04, 0.04)
                ..translate(-bounds.left, -bounds.top))
              .storage,
        ),
        Paint()
          ..style = PaintingStyle.fill
          ..isAntiAlias = false
          ..color = const Color(0xff000000),
      );

    return recorder.endRecording().toImage(
          bounds.width.toInt() ~/ 25,
          bounds.height.toInt() ~/ 25,
        );
  }

  (int, int) _getCoordinates({
    required MapLayer layer,
    required Offset offset,
  }) {
    final bounds = layer.blocked.getBounds();
    final translated = offset.translate(-bounds.left, -bounds.top);

    final x = layer.map.width * translated.dx ~/ bounds.width;
    final y = layer.map.height * translated.dy ~/ bounds.height;

    return (x.clamp(0, layer.map.width - 1), y.clamp(0, layer.map.height - 1));
  }
}
