import 'package:flutter/material.dart';

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
            final logoSize = (shortestSide * 0.62).clamp(190.0, 360.0);

            return Center(
              child: Image.asset(
                'assets/images/brand/mira_splash_logo.png',
                width: logoSize,
                height: logoSize,
                fit: BoxFit.contain,
              ),
            );
          },
        ),
      ),
    );
  }
}
