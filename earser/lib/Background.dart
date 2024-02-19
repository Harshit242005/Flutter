// ignore: file_names
import 'package:flutter/material.dart';

class BackgroundImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/grid_pattern.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
