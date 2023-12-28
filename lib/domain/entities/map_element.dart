import 'dart:ui';

sealed class MapElemnent {
  const MapElemnent();

  static MapElemnent fromJson(Map<String, dynamic> json) {}

  Rect get constraints;

  void draw(Canvas canvas, Rect canvasConstraints);
}
