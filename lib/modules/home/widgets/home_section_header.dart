import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    required this.title,
    super.key,
    this.onSeeAll,
    this.isEmphasized = false,
  });

  final String title;
  final VoidCallback? onSeeAll;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: isEmphasized
                  ? AppColors.primary
                  : context.colors.textPrimary,
            ),
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: context.colors.textPrimary,
            ),
            child: Text(
              'See All',
              style: AppTextStyles.bodyLarge.copyWith(fontSize: 16),
            ),
          ),
      ],
    );
  }
}
