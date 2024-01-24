import 'dart:convert';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/entities.dart';
import '../../domain/entities/map/map_element.dart';
import '../../domain/repositories/map_repository.dart';

class MapRepositoryImpl implements MapRepository {
  static const _wallColor = Color(0xff000000);

  @override
  Future<List<MapLayer>> getMap() async {
    final json = (jsonDecode(await rootBundle.loadString('assets/test.json'))
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

    final image = await _generateMap(blocked: blocked);
    final pixelBuffer = (await image.toByteData())!.buffer.asUint8List();
    final pixelWidth = image.width;
    final pixelHeight = image.height;

    return [
      MapLayer(
        walls: walls,
        blocked: blocked,
        doors: doors,
        image: image,
        pixelList: pixelBuffer,
        pixelWidth: pixelWidth,
        pixelHeight: pixelHeight,
      ),
    ];
  }

  @override
  Future<List<Offset>> findPath({
    required MapLayer layer,
    required Offset start,
    required Offset end,
  }) async {
    final startIndex = _offsetToPoint(layer: layer, offset: start);
    final endIndex = _offsetToPoint(layer: layer, offset: end);

    if (layer.getPixel(startIndex).value == 0x00000000 ||
        layer.getPixel(endIndex).value == 0x00000000) {
      return Future.value([]);
    }

    final cameFrom = <Point, Point>{};
    final gScore = <Point, double>{};
    final fScore = <Point, double>{};
    final openSet = HeapPriorityQueue<Point>(
      (a, b) => fScore[a]!.compareTo(fScore[b]!),
    );

    gScore[startIndex] = 0;
    fScore[startIndex] = _heuristicCostEstimate(startIndex, endIndex);

    openSet.add(startIndex);

    while (openSet.isNotEmpty) {
      final current = openSet.removeFirst();
      if (current == endIndex) {
        return Future.value(
          _reconstructPath(cameFrom, current)
              .map((e) => _pointToOffset(layer: layer, point: e))
              .toList(),
        );
      }

      for (final neighbor in _getNeighbors(current, layer)) {
        final tentativeGScore =
            gScore[current]! + _distBetween(current, neighbor);
        if (tentativeGScore < (gScore[neighbor] ?? double.infinity)) {
          cameFrom[neighbor] = current;
          gScore[neighbor] = tentativeGScore;
          fScore[neighbor] =
              gScore[neighbor]! + _heuristicCostEstimate(neighbor, endIndex);
          if (!openSet.contains(neighbor)) {
            openSet.add(neighbor);
          }
        }
      }
    }

    return Future.value([]);
  }

  Future<Image> _generateMap({
    required Path blocked,
  }) async {
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
          ..color = _wallColor,
      );

    return recorder.endRecording().toImage(
          bounds.width.toInt() ~/ 25,
          bounds.height.toInt() ~/ 25,
        );
  }

  Point _offsetToPoint({
    required MapLayer layer,
    required Offset offset,
  }) {
    final bounds = layer.blocked.getBounds();
    final translated = offset.translate(-bounds.left, -bounds.top);

    final x = layer.pixelWidth * translated.dx ~/ bounds.width;
    final y = layer.pixelHeight * translated.dy ~/ bounds.height;

    return Point(
      x: x.clamp(0, layer.pixelWidth - 1),
      y: y.clamp(0, layer.pixelHeight - 1),
    );
  }

  Offset _pointToOffset({
    required MapLayer layer,
    required Point point,
  }) {
    final bounds = layer.blocked.getBounds();

    final x = bounds.width * point.x / layer.pixelWidth + bounds.left;
    final y = bounds.height * point.y / layer.pixelHeight + bounds.top;

    return Offset(x, y);
  }

  double _heuristicCostEstimate(Point a, Point b) {
    return (a.x - b.x).abs() + (a.y - b.y).abs().toDouble();
  }

  double _distBetween(Point a, Point b) {
    return (a.x - b.x).abs() + (a.y - b.y).abs().toDouble();
  }

  List<Point> _reconstructPath(Map<Point, Point> cameFrom, Point current) {
    if (cameFrom.containsKey(current)) {
      return _reconstructPath(cameFrom, cameFrom[current]!)..add(current);
    } else {
      return [current];
    }
  }

  List<Point> _getNeighbors(Point current, MapLayer layer) {
    final neighbors = <Point>[];
    for (var dx = -1; dx <= 1; dx++) {
      for (var dy = -1; dy <= 1; dy++) {
        if (dx == 0 && dy == 0) {
          continue;
        }

        final neighbor = Point(
          x: current.x + dx,
          y: current.y + dy,
        );

        if (layer.getPixel(neighbor) != _wallColor) {
          neighbors.add(neighbor);
        }
      }
    }

    return neighbors;
  }
}
