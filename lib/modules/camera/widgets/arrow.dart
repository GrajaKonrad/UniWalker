import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uni_walker/modules/camera/painters/arrow_painter.dart';

class Arrow extends StatefulWidget {
  const Arrow({super.key});

  @override
  State<Arrow> createState() => _ArrowState();
}

class _ArrowState extends State<Arrow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() => setState(() {}));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationX(.25 * pi) *
          Matrix4.rotationZ(2 * pi * _animation.value),
      child: SizedBox(
        width: 92,
        height: 92,
        child: CustomPaint(
          painter: ArrowPainter(),
        ),
      ),
    );
  }
}
