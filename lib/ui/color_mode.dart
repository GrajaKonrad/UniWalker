import 'dart:ui';

import 'colors.dart';

class ColorMode {
  const ColorMode({
    required this.backgroud,
  });

  final Color backgroud;

  static const light = ColorMode(
    backgroud: AppColors.grayscale50,
  );
  // static const dark = ColorMode();
}
