import 'package:flutter/material.dart';

class AveroLogo extends StatelessWidget {
  const AveroLogo({super.key, this.size = 112});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/brand/avero_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
