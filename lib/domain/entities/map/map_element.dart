import 'dart:math';
import 'dart:ui';

import 'package:meta/meta.dart';

part 'arc.dart';
part 'line.dart';

@immutable
sealed class MapElement {
  const MapElement();

  /// Creates a [MapElement] from the given json.
  /// Throws an [Exception] if the type is not supported.
  /// Supported types are: [Line], [Arc]
  static MapElement fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'line' => Line.fromJson(json),
      'arc' => Arc.fromJson(json),
      _ => throw Exception(),
    };
  }

  /// Adds the shape to the given path.
  Path add({
    required Path path,
  });

  /// Checks if the shape intersects with the given line.
  bool isIntersecting({
    required Offset p1,
    required Offset p2,
  });

  // pixel pathfinding
  Path addWithPadding({
    required Path path,
    required double padding,
  });
}
