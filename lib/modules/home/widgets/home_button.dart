import 'package:flutter/material.dart';

import '../../../ui/colors.dart';

class HomeButton extends StatelessWidget {
  const HomeButton({
    required this.text,
    this.onTap,
    this.icon,
    super.key,
  });

  final void Function()? onTap;
  final String text;
  final Widget? icon;

  static const borderRadius = 8.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 48,
      child: Material(
        color: AppColors.primary800,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 8,
              top: 8,
              bottom: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                ),
                if (icon != null)
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      color: AppColors.primary50,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: icon,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
