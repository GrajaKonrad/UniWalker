import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/map_repository.dart';
import '../painters/map_painter.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({
    required this.mapLayers,
    required this.constraints,
    super.key,
  });

  final List<MapLayer> mapLayers;
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

  Offset? _start;
  Offset? _end;

  List<Offset>? _path;

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
    return GestureDetector(
      onTapDown: (details) => _setStart(
        _transformationController.toScene(
          details.localPosition,
        ),
      ),
      onDoubleTapDown: (details) => _setEnd(
        _transformationController.toScene(
          details.localPosition,
        ),
      ),
      child: InteractiveViewer(
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
                      offset: _mapOffset,
                      scale: _mapScale,
                      path: _start != null && _end != null
                          ? [_start!, _end!]
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _setStart(Offset offset) {
    setState(() {
      _start = offset - const Offset(_padding, _padding);
      _findPath();
    });
  }

  void _setEnd(Offset offset) {
    setState(() {
      _end = offset - const Offset(_padding, _padding);
      _findPath();
    });
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

  Future<void> _findPath() async {
    if (_start == null || _end == null) {
      return _path = null;
    }

    final start = _start! / _mapScale + _mapOffset;
    final end = _end! / _mapScale + _mapOffset;

    final path = await context.read<MapRepository>().findPath(
          layer: widget.mapLayers[_layerIndex],
          start: start,
          end: end,
        );

    if (!mounted) {
      return;
    }
    setState(() {
      _path = path;
    });
  }
}
