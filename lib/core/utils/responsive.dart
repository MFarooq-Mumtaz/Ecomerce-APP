import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Screen size classes used across Avero.
///
/// compact  : phones (< 600 wide)
/// medium   : large phones in landscape, small tablets (600 - 1023)
/// expanded : tablets in landscape, desktop (>= 1024)
enum ScreenType { compact, medium, expanded }

/// Width-based layout values, always created from [LayoutBuilder]
/// constraints so a widget adapts to the space it actually gets.
class Responsive {
  const Responsive._(this.width, this.height);

  factory Responsive.fromConstraints(BoxConstraints constraints) {
    return Responsive._(constraints.maxWidth, constraints.maxHeight);
  }

  static const mediumBreakpoint = 600.0;
  static const expandedBreakpoint = 1024.0;

  /// Maximum content widths, so screens do not stretch on tablets.
  static const authMaxWidth = 440.0;
  static const formMaxWidth = 520.0;
  static const listMaxWidth = 760.0;
  static const gridMaxWidth = 1200.0;

  final double width;
  final double height;

  ScreenType get type {
    if (width >= expandedBreakpoint) {
      return ScreenType.expanded;
    }
    if (width >= mediumBreakpoint) {
      return ScreenType.medium;
    }
    return ScreenType.compact;
  }

  bool get isCompact => type == ScreenType.compact;
  bool get isMedium => type == ScreenType.medium;
  bool get isExpanded => type == ScreenType.expanded;

  /// Very narrow phones (e.g. 320 wide) get tighter spacing.
  bool get isSmallPhone => width < 360;

  /// Side padding for the current screen size.
  double get pagePadding {
    if (isSmallPhone) {
      return 16;
    }
    switch (type) {
      case ScreenType.compact:
        return 24;
      case ScreenType.medium:
        return 32;
      case ScreenType.expanded:
        return 40;
    }
  }

  /// Side padding that also centers content inside [maxContentWidth].
  double horizontalPadding(double maxContentWidth) {
    return math.max(pagePadding, (width - maxContentWidth) / 2);
  }

  /// Padding for a scrolling page whose content is centered on wide screens.
  /// The scroll view itself stays full width, so it scrolls from anywhere.
  EdgeInsets pageInsets({
    double maxContentWidth = listMaxWidth,
    double top = 16,
    double bottom = 32,
  }) {
    final horizontal = horizontalPadding(maxContentWidth);
    return EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom);
  }

  /// Width left for content after [horizontalPadding] on both sides.
  double contentWidth(double maxContentWidth) {
    return width - (horizontalPadding(maxContentWidth) * 2);
  }

  /// How many grid columns fit when every item needs at least
  /// [minItemWidth].
  int columnsFor({
    required double minItemWidth,
    double spacing = 16,
    double maxContentWidth = gridMaxWidth,
    int minColumns = 1,
    int maxColumns = 6,
  }) {
    final available = contentWidth(maxContentWidth);
    final columns = ((available + spacing) / (minItemWidth + spacing)).floor();
    return columns.clamp(minColumns, maxColumns);
  }

  /// Width of one item when [columns] items share a row.
  double itemWidth({
    required int columns,
    double spacing = 16,
    double maxContentWidth = gridMaxWidth,
  }) {
    final available = contentWidth(maxContentWidth);
    return (available - (spacing * (columns - 1))) / columns;
  }
}

/// [LayoutBuilder] that hands the child a ready [Responsive] object.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({required this.builder, super.key});

  final Widget Function(BuildContext context, Responsive layout) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return builder(context, Responsive.fromConstraints(constraints));
      },
    );
  }
}

/// Centers a non-scrolling block (e.g. a bottom summary bar) with the same
/// side padding and max width as the scrolling content above it.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    required this.child,
    super.key,
    this.maxContentWidth = Responsive.listMaxWidth,
    this.top = 0,
    this.bottom = 0,
  });

  final Widget child;
  final double maxContentWidth;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, layout) {
        return Padding(
          padding: layout.pageInsets(
            maxContentWidth: maxContentWidth,
            top: top,
            bottom: bottom,
          ),
          child: child,
        );
      },
    );
  }
}
