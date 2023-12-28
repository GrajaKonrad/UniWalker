import 'package:flutter/material.dart';

import '../../ui/colors.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({
    super.title,
    super.key,
  }) : super(
          backgroundColor: AppColors.primary800,
          foregroundColor: AppColors.primary50,
          elevation: 1,
          shadowColor: AppColors.black,
        );
}
