import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/entities.dart';
import '../cubit/map_cubit.dart';
import '../painters/map_painter.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({
    required this.mapLayers,
    required this.constraints,
    super.key,
  });

  final List<Floor> mapLayers;
  final BoxConstraints constraints;

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  static const _padding = 16.0;

  final _transformationController = TransformationController();
  int _layerIndex = 0;
  Offset _mapOffset = Offset.zero;
  double _mapScale = 1;

  @override
  void initState() {
    super.initState();
    _setLayer(0);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapState>(
      builder: (context, state) {
        final path = state is MapLoaded ? state.path : null;

        return InteractiveViewer(
          transformationController: _transformationController,
          child: Padding(
            padding: const EdgeInsets.all(_padding),
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    child: CustomPaint(
                      painter: MapPainter(
                        walls: widget.mapLayers[_layerIndex].walls,
                        doors: widget.mapLayers[_layerIndex].doors,
                        floor: widget.mapLayers[_layerIndex],
                        offset: _mapOffset,
                        scale: _mapScale,
                        path: path,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _setLayer(int index) {
    setState(() {
      final bounds = widget.mapLayers[index].walls.getBounds();

      _mapScale = min(
        (widget.constraints.maxWidth - 2 * _padding) / bounds.width,
        (widget.constraints.maxHeight - 2 * _padding) / bounds.height,
      );
      _mapOffset = bounds.topLeft;
      _layerIndex = index;
    });
  }
}
