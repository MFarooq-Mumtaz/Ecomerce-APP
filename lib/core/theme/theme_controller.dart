import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/theme_storage_service.dart';

/// App-wide Light / Dark / System theme choice.
///
/// Registered once in main() (permanent), before the first frame, so the
/// app starts directly in the saved mode without a light-to-dark flash.
class ThemeController extends GetxController {
  ThemeController(this._storage, {ThemeMode initialMode = ThemeMode.system})
    : themeMode = initialMode.obs;

  final ThemeStorageService _storage;

  final Rx<ThemeMode> themeMode;

  /// Applies [mode] to the whole app and remembers it for the next launch.
  Future<void> changeThemeMode(ThemeMode mode) async {
    if (themeMode.value == mode) {
      return;
    }
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    await _storage.saveThemeMode(mode);
  }

  static String shortLabelFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  static IconData iconFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      case ThemeMode.system:
        return Icons.brightness_auto_outlined;
    }
  }
}
