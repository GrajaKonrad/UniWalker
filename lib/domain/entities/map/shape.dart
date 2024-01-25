import 'dart:math';
import 'dart:ui';

import 'package:meta/meta.dart';

part 'arc.dart';
part 'line.dart';

@immutable
sealed class Shape {
  const Shape();

  /// Creates a [Shape] from the given json.
  /// Throws an [Exception] if the type is not supported.
  /// Supported types are: [Line], [Arc]
  static Shape fromJson(Map<String, dynamic> json) {
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

  List<Offset> get points;
  Offset get center;
}
