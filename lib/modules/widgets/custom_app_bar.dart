import 'package:flutter/material.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({
    super.title,
    super.key,
  }) : super(
          backgroundColor: Colors.deepPurpleAccent,
          foregroundColor: Colors.white,
          elevation: 1,
          shadowColor: Colors.black,
        );
}
