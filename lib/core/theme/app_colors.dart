import 'package:flutter/material.dart';

/// Brand colors that are the same in light and dark mode.
///
/// Background, surface and text colors depend on the theme mode, so they
/// live in [AppPalette] and are read with `context.colors`.
abstract final class AppColors {
  static const primary = Color(0xFF8E6CEF);

  static const error = Color(0xFFFA3636);
  static const success = Color(0xFF5FB567);
  static const warning = Color(0xFFF4BD2F);
}
