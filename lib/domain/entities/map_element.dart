import 'dart:math';

import 'package:flutter/material.dart';

part 'arc.dart';
part 'line.dart';

sealed class MapElement {
  const MapElement();

  static MapElement fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'line' => Line.fromJson(json),
      'arc' => Arc.fromJson(json),
      _ => throw Exception(),
    };
  }

  Path add({
    required Path path,
  });

  Path addWithPadding({
    required Path path,
    required double padding,
  });
}
