import 'package:flutter/material.dart';

import '../../../core/widgets/avero_logo.dart';
import '../../../core/theme/app_colors.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Padding(
              padding: EdgeInsets.all(22),
              child: AveroLogo(size: 128),
            ),
          ),
        ),
      ),
    );
  }
}
