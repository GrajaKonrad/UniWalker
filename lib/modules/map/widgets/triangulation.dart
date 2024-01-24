import 'dart:math';

import 'package:flutter/material.dart';

import '../painters/test_painter.dart';

class Triangulation extends StatefulWidget {
  const Triangulation({
    required this.constraints,
    super.key,
  });

  final BoxConstraints constraints;

  @override
  State<Triangulation> createState() => _TriangulationState();
}

class _TriangulationState extends State<Triangulation> {
  final List<Offset> _points = <Offset>[];

  @override
  void initState() {
    final rand = Random();

    _points
      ..add(Offset.zero)
      ..add(Offset(0, widget.constraints.maxHeight))
      ..add(Offset(widget.constraints.maxWidth, 0))
      ..add(Offset(widget.constraints.maxWidth, widget.constraints.maxHeight));
    for (var i = 0; i < 100; i++) {
      _points.add(
        Offset(
          rand.nextDouble() * widget.constraints.maxWidth,
          rand.nextDouble() * widget.constraints.maxHeight,
        ),
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: double.maxFinite,
            height: double.maxFinite,
            child: CustomPaint(
              painter: TestPainter(
                points: _points,
              ),
            ),
          );
        },
      ),
    );
  }
}
