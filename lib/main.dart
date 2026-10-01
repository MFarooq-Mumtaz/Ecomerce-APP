import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/app.dart';
import 'core/theme/theme_controller.dart';
import 'data/services/theme_storage_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The saved Light / Dark / System choice is read before the first frame,
  // so the app never flashes the wrong theme on startup.
  final themeStorage = ThemeStorageService();
  final results = await Future.wait<Object?>([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    themeStorage.readThemeMode(),
  ]);
  Get.put(
    ThemeController(themeStorage, initialMode: results[1] as ThemeMode),
    permanent: true,
  );

  runApp(const AveroApp());
}
