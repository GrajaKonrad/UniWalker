import 'package:flutter/material.dart';
import 'package:uni_walker/domain/entities/map_layer.dart';
import 'package:uni_walker/domain/entities/obstacle.dart';
import 'package:uni_walker/modules/camera/painters/map_painter.dart';

class MapPanel extends StatefulWidget {
  const MapPanel({super.key});

  @override
  State<MapPanel> createState() => _MapPanelState();
}

class _MapPanelState extends State<MapPanel> {
  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      child: Center(
        child: CustomPaint(
          painter: MapPainter(
            layer: MapLayer(
              floor: 0,
              obstacle: [
                Obstacle(
                  vertices: [
                    Offset(10, 10),
                    Offset(10, 80),
                    Offset(20, 80),
                    Offset(20, 10),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
