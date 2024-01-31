import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/entities.dart';
import '../../domain/repositories/map_repository.dart';

class MapRepositoryImpl implements MapRepository {
  @override
  Future<List<Floor>> getMap() async {
    final json = jsonDecode(await rootBundle.loadString('assets/map.json'))
        as List<dynamic>;

    return json.map((e) => Floor.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Offset>> findPath({
    required Floor layer,
    required Offset start,
    required Offset end,
  }) async {
    final cameFrom = <Offset, Offset>{};
    final gScore = <Offset, double>{};
    final fScore = <Offset, double>{};
    final openSet = HeapPriorityQueue<Offset>(
      (a, b) => fScore[a]!.compareTo(fScore[b]!),
    );

    final endNode = layer.graph.keys.firstWhereOrNull((e) => e == end) ??
        layer.triangles.firstWhere((e) => e.isPointInside(end)).center;

    gScore[start] = 0;
    fScore[endNode] = _heuristicCostEstimate(start, endNode);

    // insert artificial edges
    for (final node in layer.graph.keys) {
      if (!layer.obstacles.any((e) => e.isIntersecting(p1: start, p2: node))) {
        cameFrom[node] = start;
        gScore[node] = _distBetween(start, node);
        fScore[node] = _heuristicCostEstimate(node, endNode);
        openSet.add(node);
      }
    }

    while (openSet.isNotEmpty) {
      final current = openSet.removeFirst();
      if (current == endNode) {
        return Future.value(_reconstructPath(cameFrom, current));
      }

      for (final neighbor in layer.graph[current] ?? <Offset>[]) {
        final tentativeGScore =
            gScore[current]! + _distBetween(current, neighbor);
        if (tentativeGScore < (gScore[neighbor] ?? double.infinity)) {
          cameFrom[neighbor] = current;
          gScore[neighbor] = tentativeGScore;
          fScore[neighbor] =
              gScore[neighbor]! + _heuristicCostEstimate(neighbor, endNode);
          if (!openSet.contains(neighbor)) {
            openSet.add(neighbor);
          }
        }
      }
    }

    return Future.value(<Offset>[]);
  }

  double _heuristicCostEstimate(Offset a, Offset b) {
    return (a - b).distance;
  }

  double _distBetween(Offset a, Offset b) {
    return (a - b).distance;
  }

  List<Offset> _reconstructPath(Map<Offset, Offset> cameFrom, Offset current) {
    if (cameFrom.containsKey(current)) {
      return _reconstructPath(cameFrom, cameFrom[current]!)..add(current);
    } else {
      return [current];
    }
  }
}
