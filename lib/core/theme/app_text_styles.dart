import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  // Temporary fallback until Circular Std and Gabarito font files are added.
  static const String fallbackFontFamily = 'Roboto';

  static const headlineLarge = TextStyle(
    fontFamily: fallbackFontFamily,
    fontSize: 32,
    height: 34.5 / 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const titleLarge = TextStyle(
    fontFamily: fallbackFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const titleMedium = TextStyle(
    fontFamily: fallbackFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const bodyLarge = TextStyle(
    fontFamily: fallbackFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontFamily: fallbackFontFamily,
    fontSize: 12,
    height: 1.6,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
}
