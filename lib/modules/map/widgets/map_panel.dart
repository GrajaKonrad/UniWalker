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
  double scale = 1.0;
  Offset offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          offset += details.delta;
          print(offset);
        });
      },
      // onScaleUpdate: (details) {
      //   setState(() {
      //     scale = scale * details.scale;
      //     print(scale);
      //   });
      // },
      // onVerticalDragUpdate: (details) {
      //   setState(() {
      //     offset += details.delta;
      //     print(offset);
      //   });
      // },
      // onHorizontalDragUpdate: (details) {
      //   setState(() {
      //     offset += details.delta;
      //     print(offset);
      //   });
      // },
      child: Center(
        child: SizedBox(
          width: 500,
          height: 500,
          child: Transform.translate(
            offset: offset,
            child: const CustomPaint(
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
        ),
      ),
    );
  }
}
