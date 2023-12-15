import 'package:flutter/material.dart';

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

  static const borderRadius = 16.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 256,
      height: 64,
      child: Material(
        color: Colors.deepPurpleAccent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 32,
              right: 16,
              top: 8,
              bottom: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                ),
                if (icon != null) icon!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
