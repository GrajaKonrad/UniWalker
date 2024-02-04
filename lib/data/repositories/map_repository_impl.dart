import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:delaunay/delaunay.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/entities.dart';
import '../../domain/repositories/map_repository.dart';

class MapRepositoryImpl implements MapRepository {
  @override
  Future<Building> getMap() async {
    final json = jsonDecode(await rootBundle.loadString('assets/map.json'))
        as List<dynamic>;

    final data = json
        .map((e) => _readFloor(e as Map<String, dynamic>))
        .sorted((a, b) => a.$1.level.compareTo(b.$1.level));

    final floors = data.map((e) => e.$1).toList();
    final navigationGraph = data.map((e) => e.$2).toList().reduce((a, b) {
      a.addAll(b);
      return a;
    });
    for (final floor in data) {
      for (final stairs in floor.$3) {
        final from = Position(
          x: stairs.x,
          y: stairs.y,
          level: floor.$1.level,
        );
        final to = Position(
          x: stairs.x,
          y: stairs.y,
          level: stairs.targetFloor,
        );

        if (from == to) {
          continue;
        }

        navigationGraph.putIfAbsent(from, () => <Position>[]).add(to);

        for (final node in navigationGraph.entries.where(
          (e) => e.key.level == to.level,
        )) {
          if (node.key == to) {
            continue;
          }

          if (Offset(node.key.x - to.x, node.key.y - to.y).distanceSquared >=
              20 * 20 * 100 * 100) {
            continue;
          }

          if (floor.$4.any(
            (e) => e.isIntersecting(
              p1: Offset(to.x, to.y),
              p2: Offset(node.key.x, node.key.y),
            ),
          )) {
            continue;
          }

          navigationGraph[to]?.add(node.key);
        }
      }
    }
    final obstacles = Map.fromEntries(
      data.map((e) => MapEntry(e.$1.level, e.$4)),
    );

    return Future.value(
      Building(
        floors: floors,
        navigationGraph: navigationGraph,
        obstacles: obstacles,
      ),
    );
  }

  @override
  Future<List<Position>> findPath({
    required Building building,
    required Position start,
    required Position end,
  }) async {
    final cameFrom = <Position, Position>{};
    final gScore = <Position, double>{};
    final fScore = <Position, double>{};
    final openSet = HeapPriorityQueue<Position>(
      (a, b) => fScore[a]!.compareTo(fScore[b]!),
    );

    final endNode = end;

    gScore[start] = 0;
    fScore[endNode] = _heuristicCostEstimate(start, endNode);

    // insert artificial edges
    for (final node in building.navigationGraph.keys) {
      final obstacles = building.obstacles[node.level] ?? <Shape>[];

      if (!obstacles.any(
        (e) => e.isIntersecting(
          p1: Offset(start.x, start.y),
          p2: Offset(node.x, node.y),
        ),
      )) {
        cameFrom[node] = start;
        gScore[node] = _distBetween(start, node);
        fScore[node] = _heuristicCostEstimate(node, endNode);
        openSet.add(node);
      }
    }

    while (openSet.isNotEmpty) {
      final current = openSet.removeFirst();
      if (current == endNode) {
        cameFrom.remove(start);
        return Future.value(_reconstructPath(cameFrom, current));
      }

      for (final neighbor
          in building.navigationGraph[current] ?? <Position>[]) {
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

    return Future.value(<Position>[]);
  }

  (
    Floor floor,
    Map<Position, List<Position>> graph,
    List<Stairs> stairs,
    List<Shape> obstacles,
  ) _readFloor(Map<String, dynamic> json) {
    final level = (json['level'] as num).toInt();
    final walls = _readShapes(json['walls'] as List<dynamic>);
    final doors = _readShapes(json['doors'] as List<dynamic>);
    final stairs = _readStairs(json['stairs'] as List<dynamic>);
    final rooms = _readRooms(json['rooms'] as List<dynamic>);

    final nodes = <Offset>{}
      ..addAll(_delaunayCenters(walls))
      ..addAll(doors.expand((e) => [e.centerPoints.$1, e.centerPoints.$2]))
      ..addAll(stairs.map((e) => Offset(e.x, e.y)).toList())
      ..addAll(rooms.map((e) => Offset(e.x, e.y)).toList());

    final graph = <Position, List<Position>>{};

    for (final door in doors) {
      final (a, b) = door.centerPoints;
      graph
          .putIfAbsent(_positionFromOffset(a, level), () => <Position>[])
          .add(_positionFromOffset(b, level));
      graph
          .putIfAbsent(_positionFromOffset(b, level), () => <Position>[])
          .add(_positionFromOffset(a, level));
    }
    for (final a in nodes) {
      final posA = _positionFromOffset(a, level);

      graph.putIfAbsent(posA, () => <Position>[]);
      for (final b in nodes) {
        if (a == b) {
          continue;
        }

        if ((a - b).distanceSquared >= 20 * 20 * 100 * 100) {
          continue;
        }

        if (walls.any((e) => e.isIntersecting(p1: a, p2: b)) ||
            doors.any((e) => e.isIntersecting(p1: a, p2: b))) {
          continue;
        }

        graph[posA]?.add(_positionFromOffset(b, level));
      }
    }

    final wallsPath = Path();
    final doorsPath = Path();

    for (final e in walls) {
      e.add(path: wallsPath);
    }

    for (final e in doors) {
      e.add(path: doorsPath);
    }

    final floor = Floor(
      level: level,
      walls: wallsPath,
      doors: doorsPath,
      rooms: rooms,
    );

    return (floor, graph, stairs, walls + doors);
  }

  List<Shape> _readShapes(List<dynamic> json) {
    return json.map((e) => Shape.fromJson(e as Map<String, dynamic>)).toList();
  }

  List<Stairs> _readStairs(List<dynamic> json) {
    return json
        .map((e) => e as Map<String, dynamic>)
        .map(
          (e) => Stairs(
            x: (e['x'] as num).toDouble(),
            y: (e['y'] as num).toDouble(),
            targetFloor: (e['target'] as num).toInt(),
          ),
        )
        .toList();
  }

  List<Room> _readRooms(List<dynamic> json) {
    return json
        .map((e) => e as Map<String, dynamic>)
        .map(
          (e) => Room(
            x: (e['x'] as num).toDouble(),
            y: (e['y'] as num).toDouble(),
            name: e['name'] as String,
          ),
        )
        .toList();
  }

  List<Offset> _delaunayCenters(List<Shape> shapes) {
    final result = <Offset>[];

    final delaunay = Delaunay.from(
      shapes
          .expand((e) => e.points)
          .toSet()
          .map((e) => Point(e.dx, e.dy))
          .toList(),
    )..update();
    final delaunayCoords = delaunay.coords;
    final delaunayTriangles = delaunay.triangles;
    for (var i = 0; i < delaunayTriangles.length; i += 3) {
      final p1 = Offset(
        delaunayCoords[2 * delaunayTriangles[i]],
        delaunayCoords[2 * delaunayTriangles[i] + 1],
      );
      final p2 = Offset(
        delaunayCoords[2 * delaunayTriangles[i + 1]],
        delaunayCoords[2 * delaunayTriangles[i + 1] + 1],
      );
      final p3 = Offset(
        delaunayCoords[2 * delaunayTriangles[i + 2]],
        delaunayCoords[2 * delaunayTriangles[i + 2] + 1],
      );
      final triangle = Triangle(a: p1, b: p2, c: p3);
      if (triangle.area < 10000) {
        continue;
      }
      result.add(triangle.inscribedCircleCenter);
    }

    return result;
  }

  Position _positionFromOffset(Offset offset, int level) {
    return Position(x: offset.dx, y: offset.dy, level: level);
  }

  double _heuristicCostEstimate(Position a, Position b) {
    return Offset(a.x - b.x, a.y - b.y).distance +
        (a.level - b.level).abs() * 500;
  }

  double _distBetween(Position a, Position b) {
    return Offset(a.x - b.x, a.y - b.y).distance +
        (a.level - b.level).abs() * 500;
  }

  List<Position> _reconstructPath(
    Map<Position, Position> cameFrom,
    Position current,
  ) {
    if (cameFrom.containsKey(current)) {
      return _reconstructPath(cameFrom, cameFrom[current]!)..add(current);
    } else {
      return [current];
    }
  }
}
