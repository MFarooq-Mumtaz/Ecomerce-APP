import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'bindings/initial_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'theme/app_palette.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'widgets/unfocus_on_tap.dart';

class AveroApp extends StatelessWidget {
  const AveroApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return GetMaterialApp(
      title: 'Avero',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Later changes go through ThemeController -> Get.changeThemeMode.
      themeMode: themeController.themeMode.value,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      builder: (context, child) {
        // Large system fonts still scale the UI, but are capped at 1.3x so
        // cards and rows keep their layout on every phone.
        final isDark = Theme.of(context).brightness == Brightness.dark;
        // Status bar and Android navigation bar follow the theme on screens
        // without an AppBar (Home, Profile, Login...).
        final systemBars =
            (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
                .copyWith(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: context.colors.background,
                  systemNavigationBarIconBrightness: isDark
                      ? Brightness.light
                      : Brightness.dark,
                );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: systemBars,
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            // One app-wide wrapper: tapping outside a text field closes the
            // keyboard on every screen.
            child: UnfocusOnTap(child: child ?? const SizedBox.shrink()),
          ),
        );
      },
    );
  }
}
