import 'package:flutter/material.dart';

/// Neutral colors that change between light and dark mode.
///
/// Brand colors that stay the same in both modes (primary, error, success,
/// warning) live in [AppColors]. Read these with `context.colors`, so a
/// widget picks up the right set when the theme changes.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textMuted,
    required this.placeholder,
  });

  /// Page / scaffold background.
  final Color background;

  /// Cards, inputs, chips and other raised areas.
  final Color surface;

  final Color textPrimary;

  /// Secondary text, hints and inactive icons.
  final Color textMuted;

  /// Behind product images while they load or when they are missing.
  final Color placeholder;

  static const light = AppPalette(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF4F4F4),
    textPrimary: Color(0xFF272727),
    textMuted: Color(0x80272727),
    placeholder: Color(0xFFE7E7E7),
  );

  /// Dark colors from the Avero design.
  static const dark = AppPalette(
    background: Color(0xFF1D182A),
    surface: Color(0xFF342F3F),
    textPrimary: Color(0xFFFFFFFF),
    textMuted: Color(0x99FFFFFF),
    placeholder: Color(0xFF2A2536),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textMuted,
    Color? placeholder,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      placeholder: placeholder ?? this.placeholder,
    );
  }

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) {
      return this;
    }
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      placeholder: Color.lerp(placeholder, other.placeholder, t)!,
    );
  }
}

extension AppPaletteContext on BuildContext {
  /// Theme-aware Avero colors, e.g. `context.colors.surface`.
  AppPalette get colors {
    return Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
  }
}
