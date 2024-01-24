import 'dart:typed_data';
import 'dart:ui';

import 'package:meta/meta.dart';

import '../point.dart';

@immutable
class MapLayer {
  const MapLayer({
    required this.walls,
    required this.doors,
    required this.blocked,
    required this.image,
    required this.pixelList,
    required this.pixelWidth,
    required this.pixelHeight,
  });

  final Path walls;
  final Path doors;
  final Path blocked;

  // pixel pathfinding
  final Image image;
  final Uint8List pixelList;
  final int pixelWidth;
  final int pixelHeight;

  // navigaion graph

  Color getPixel(Point index) {
    if (index.x < 0 ||
        index.x >= pixelWidth ||
        index.y < 0 ||
        index.y >= pixelHeight) {
      return const Color(0x00000000);
    }

    final offset = ((pixelWidth * index.y) + index.x) * 4;

    return Color.fromARGB(
      pixelList[offset + 3],
      pixelList[offset],
      pixelList[offset + 1],
      pixelList[offset + 2],
    );
  }
}
