import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/map_repository.dart';
import '../../../logger.dart';
import '../../camera/painters/map_painter.dart';

class MapPanel extends StatelessWidget {
  const MapPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<MapRepository>().getMap(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return InteractiveViewer(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final boundries = snapshot.data!.first.boundries;
                    final aspectRatio = (boundries.bottom - boundries.top) /
                        (boundries.right - boundries.left);

                    return CustomPaint(
                      painter: MapPainter(layer: snapshot.data!.first),
                      child: constraints.maxWidth * aspectRatio <
                              constraints.maxHeight
                          ? SizedBox(
                              width: constraints.maxWidth,
                              height: constraints.maxWidth * aspectRatio,
                            )
                          : SizedBox(
                              width: constraints.maxHeight / aspectRatio,
                              height: constraints.maxHeight,
                            ),
                    );
                  },
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          Logger.error(snapshot.error);
          return const Center(
            child: Text('Ups! Coś poszło nie tak!'),
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
