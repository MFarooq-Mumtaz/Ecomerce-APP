import 'package:flutter/material.dart';

/// Two form fields side by side, stacked vertically when the available
/// width is too narrow for both (e.g. small phones or large fonts).
class ResponsiveFieldPair extends StatelessWidget {
  const ResponsiveFieldPair({
    required this.first,
    required this.second,
    super.key,
    this.spacing = 12,
    this.stackedSpacing = 12,
    this.stackBelowWidth = 340,
  });

  final Widget first;
  final Widget second;

  /// Gap between the fields when they sit side by side.
  final double spacing;

  /// Gap between the fields when they are stacked.
  final double stackedSpacing;
  final double stackBelowWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < stackBelowWidth) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              first,
              SizedBox(height: spacing),
              second,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            SizedBox(width: spacing),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}
