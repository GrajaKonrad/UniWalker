import 'package:flutter/material.dart';

import '../../../domain/entities/map_layer.dart';
import '../../../domain/entities/obstacle.dart';
import '../../camera/painters/map_painter.dart';

class MapPanel extends StatelessWidget {
  const MapPanel({super.key});

  @override
<<<<<<< Updated upstream
  State<MapPanel> createState() => _MapPanelState();
}

class _MapPanelState extends State<MapPanel> {
  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      child: Center(
=======
  Widget build(BuildContext context) {
    return InteractiveViewer(
      child: const Center(
>>>>>>> Stashed changes
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
