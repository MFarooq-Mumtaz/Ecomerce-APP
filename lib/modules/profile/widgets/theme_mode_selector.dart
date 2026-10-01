import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_controller.dart';

/// Three selectable cards in one row: Light, Dark and System.
///
/// The row always keeps 3 equal cards; each card's preview and label scale
/// with the width it gets, from small phones to tablets.
class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({super.key});

  static const _modes = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];

  /// Wider than this, the cards stop growing so previews stay compact.
  static const _maxRowWidth = 560.0;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ThemeController>();

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxRowWidth),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Tighter spacing on very small phones.
            final spacing = constraints.maxWidth < 320 ? 8.0 : 12.0;
            final cardWidth = (constraints.maxWidth - (spacing * 2)) / 3;
            // Decided once for the whole row, so all 3 labels look the same:
            // narrow cards drop the small icon (the preview shows the mode).
            final showIcon = cardWidth >= 104;

            return Obx(() {
              final selected = controller.themeMode.value;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < _modes.length; index += 1) ...[
                    if (index > 0) SizedBox(width: spacing),
                    Expanded(
                      child: _ThemeModeCard(
                        mode: _modes[index],
                        isSelected: selected == _modes[index],
                        showIcon: showIcon,
                        onTap: () => controller.changeThemeMode(_modes[index]),
                      ),
                    ),
                  ],
                ],
              );
            });
          },
        ),
      ),
    );
  }
}

class _ThemeModeCard extends StatelessWidget {
  const _ThemeModeCard({
    required this.mode,
    required this.isSelected,
    required this.showIcon,
    required this.onTap,
  });

  final ThemeMode mode;
  final bool isSelected;
  final bool showIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(8);
    final labelColor = isSelected
        ? AppColors.primary
        : context.colors.textPrimary;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${ThemeController.shortLabelFor(mode)} theme',
      child: Material(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.12)
            : context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Padding and icon size follow the card width.
              final width = constraints.maxWidth;
              final padding = (width * 0.07).clamp(6.0, 12.0);
              final iconSize = (width * 0.14).clamp(14.0, 20.0);

              return Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 1.25,
                          child: _ThemePreview(mode: mode),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: _SelectedBadge(size: iconSize),
                          ),
                      ],
                    ),
                    SizedBox(height: padding),
                    // FittedBox is only a last safety net for extreme sizes;
                    // normally the label fits at full size.
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (showIcon) ...[
                            Icon(
                              ThemeController.iconFor(mode),
                              size: iconSize,
                              color: labelColor,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            ThemeController.shortLabelFor(mode),
                            maxLines: 1,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: labelColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SelectedBadge extends StatelessWidget {
  const _SelectedBadge({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.check_circle, size: size, color: AppColors.primary),
    );
  }
}

/// A tiny mock screen drawn in the colors of [mode]. System shows the light
/// and dark versions split diagonally.
class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.mode});

  final ThemeMode mode;

  @override
  Widget build(BuildContext context) {
    final preview = switch (mode) {
      ThemeMode.light => const _MiniScreen(palette: AppPalette.light),
      ThemeMode.dark => const _MiniScreen(palette: AppPalette.dark),
      ThemeMode.system => Stack(
        fit: StackFit.expand,
        children: [
          const _MiniScreen(palette: AppPalette.light),
          ClipPath(
            clipper: _DiagonalHalfClipper(),
            child: const _MiniScreen(palette: AppPalette.dark),
          ),
        ],
      ),
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: context.colors.textMuted.withValues(alpha: 0.25),
          ),
        ),
        child: preview,
      ),
    );
  }
}

/// Simplified app screen: a header bar, two product cards and a button,
/// all sized as fractions of the preview so it scales with the card.
class _MiniScreen extends StatelessWidget {
  const _MiniScreen({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: palette.background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final gap = width * 0.07;
          final radius = Radius.circular(width * 0.04);

          return Padding(
            padding: EdgeInsets.all(gap),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: width * 0.55,
                  height: height * 0.1,
                  decoration: BoxDecoration(
                    color: palette.textPrimary.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.all(radius),
                  ),
                ),
                SizedBox(height: gap),
                Expanded(
                  child: Row(
                    // Stretch so the two empty card boxes get full height.
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var index = 0; index < 2; index += 1) ...[
                        if (index > 0) SizedBox(width: gap),
                        Expanded(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: palette.surface,
                              borderRadius: BorderRadius.all(radius),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: gap),
                Container(
                  height: height * 0.12,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.all(Radius.circular(height)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Keeps the bottom-right triangle, so the dark half sits on the right.
class _DiagonalHalfClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
