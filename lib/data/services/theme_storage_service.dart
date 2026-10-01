import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Saves the selected Light / Dark / System mode on the device, so the app
/// opens in the same mode next time.
///
/// It uses a tiny file in the app's private support folder (path_provider
/// is already part of the app), instead of adding another plugin.
class ThemeStorageService {
  static const _fileName = 'theme_mode.txt';

  Future<ThemeMode> readThemeMode() async {
    try {
      final file = await _file();
      if (!await file.exists()) {
        return ThemeMode.system;
      }
      final saved = (await file.readAsString()).trim();
      return ThemeMode.values.firstWhere(
        (mode) => mode.name == saved,
        orElse: () => ThemeMode.system,
      );
    } catch (_) {
      // A missing or unreadable file simply means "follow the system".
      return ThemeMode.system;
    }
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    try {
      final file = await _file();
      await file.writeAsString(mode.name, flush: true);
    } catch (_) {
      // The mode still applies for this session even if saving fails.
    }
  }

  Future<File> _file() async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}${Platform.pathSeparator}$_fileName');
  }
}
