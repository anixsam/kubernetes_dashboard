import 'package:flutter/material.dart';

class GradientSquare extends StatelessWidget {
  const GradientSquare({
    super.key,
    required this.height,
    required this.width,
    required this.gradient,
  });

  final double height;
  final double width;

  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
