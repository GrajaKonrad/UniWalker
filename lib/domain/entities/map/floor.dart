import 'dart:math';
import 'dart:ui';

import 'package:delaunay/delaunay.dart';
import 'package:meta/meta.dart';

import 'entities.dart';
import 'shape.dart';

@immutable
class Floor {
  const Floor({
    required this.walls,
    required this.doors,
    required this.triangles,
    required this.graph,
  });

  factory Floor.fromJson(Map<String, dynamic> json) {
    final walls = <Shape>[];
    final doors = <Shape>[];
    final points = <Offset>{};
    final graph = <Offset, List<Offset>>{};
    final nodes = <Offset>[];
    final triangles = <Triangle>[];

    for (final wallJson in json['walls'] as List<dynamic>) {
      final wall = Shape.fromJson(wallJson as Map<String, dynamic>);
      walls.add(wall);
      points.addAll(wall.points);
    }

    final delaunay = Delaunay.from(
      points.map((e) => Point(e.dx, e.dy)).toList(),
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
      if (triangle.area() < 10000) {
        continue;
      }

      triangles.add(triangle);
      nodes.add(triangle.center);
    }

    for (final doorJson in json['doors'] as List<dynamic>) {
      final door = Shape.fromJson(doorJson as Map<String, dynamic>);
      doors.add(door);
      final (a, b) = door.centerPoints;
      nodes
        ..add(a)
        ..add(b);
      graph.putIfAbsent(a, () => <Offset>[]).add(b);
      graph.putIfAbsent(b, () => <Offset>[]).add(a);
    }

    for (final a in nodes) {
      graph.putIfAbsent(a, () => <Offset>[]);
      for (final b in nodes) {
        if ((a - b).distanceSquared >= 20 * 20 * 100 * 100) {
          continue;
        }

        if (!walls.any((e) => e.isIntersecting(p1: a, p2: b)) &&
            !doors.any((e) => e.isIntersecting(p1: a, p2: b))) {
          graph[a]!.add(b);
        }
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

    return Floor(
      walls: wallsPath,
      doors: doorsPath,
      graph: graph,
      triangles: triangles,
    );
  }

  final Path walls;
  final Path doors;
  final List<Triangle> triangles;
  final Map<Offset, List<Offset>> graph;
}
