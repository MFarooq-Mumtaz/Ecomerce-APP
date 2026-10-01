import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_layout.dart';
import 'app_colors.dart';
import 'app_palette.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light, AppPalette.light);

  static ThemeData get dark => _build(Brightness.dark, AppPalette.dark);

  /// Both modes share one definition; only the palette differs.
  static ThemeData _build(Brightness brightness, AppPalette palette) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surface: palette.background,
      onSurface: palette.textPrimary,
      onSurfaceVariant: palette.textMuted,
      error: AppColors.error,
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppLayout.inputRadius),
      borderSide: BorderSide.none,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      fontFamily: AppTextStyles.fallbackFontFamily,
      extensions: [palette],
      textTheme:
          const TextTheme(
            headlineLarge: AppTextStyles.headlineLarge,
            titleLarge: AppTextStyles.titleLarge,
            titleMedium: AppTextStyles.titleMedium,
            bodyLarge: AppTextStyles.bodyLarge,
            bodyMedium: AppTextStyles.bodyMedium,
          ).apply(
            bodyColor: palette.textPrimary,
            displayColor: palette.textPrimary,
          ),
      iconTheme: IconThemeData(color: palette.textPrimary),
      dividerTheme: DividerThemeData(color: palette.surface),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, AppLayout.buttonHeight),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white70,
          textStyle: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppLayout.pillRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.textPrimary,
          side: BorderSide(color: palette.textMuted),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppLayout.pillRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        disabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        hintStyle: AppTextStyles.bodyLarge.copyWith(color: palette.textMuted),
        labelStyle: AppTextStyles.bodyLarge.copyWith(color: palette.textMuted),
        floatingLabelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.primary,
        ),
        prefixIconColor: palette.textMuted,
        suffixIconColor: palette.textMuted,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        titleTextStyle: AppTextStyles.titleMedium.copyWith(
          color: palette.textPrimary,
        ),
        // Status bar icons must contrast with the app bar in both modes.
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: palette.textPrimary,
        textColor: palette.textPrimary,
      ),
      dialogTheme: DialogThemeData(backgroundColor: palette.background),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.background,
        modalBackgroundColor: palette.background,
        showDragHandle: true,
        dragHandleColor: palette.textMuted,
      ),
      popupMenuTheme: PopupMenuThemeData(color: palette.surface),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.background,
        indicatorColor: AppColors.primary.withValues(alpha: 0.16),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: palette.background,
        indicatorColor: AppColors.primary.withValues(alpha: 0.16),
      ),
    );
  }
}
