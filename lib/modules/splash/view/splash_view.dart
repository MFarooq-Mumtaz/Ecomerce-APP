import 'package:flutter/material.dart';

import '../../../core/widgets/avero_logo.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/responsive.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, layout) {
            // Logo scales with the shorter side: 128 on phones, larger on
            // tablets, smaller on short landscape screens.
            final shortestSide = layout.width < layout.height
                ? layout.width
                : layout.height;
            final logoSize = (shortestSide * 0.34).clamp(88.0, 180.0);

            return Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(logoSize * 0.22),
                ),
                child: Padding(
                  padding: EdgeInsets.all(logoSize * 0.17),
                  child: AveroLogo(size: logoSize),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
