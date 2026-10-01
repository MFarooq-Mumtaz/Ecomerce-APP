import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_palette.dart';

/// App-wide snackbar that follows the current light/dark theme.
///
/// GetX's default snackbar always uses black text, which is unreadable in
/// dark mode, so every message in the app goes through here.
abstract final class AppSnackbar {
  static void show(String title, String message) {
    final context = Get.context;
    final colors = context == null ? AppPalette.light : context.colors;

    Get.snackbar(
      title,
      message,
      backgroundColor: colors.surface,
      colorText: colors.textPrimary,
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
      // Keeps the snackbar a readable width on tablets.
      maxWidth: 560,
    );
  }
}
