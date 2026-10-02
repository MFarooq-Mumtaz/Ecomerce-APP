import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/product_image_url.dart';
import '../../../data/models/category_model.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = category.imageUrl;

    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : context.colors.surface,
                border: isSelected
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              clipBehavior: Clip.antiAlias,
              child: imageUrl == null || imageUrl.isEmpty
                  ? Icon(
                      Icons.category_outlined,
                      color: isSelected
                          ? Colors.white
                          : context.colors.textMuted,
                    )
                  : _CategoryImage(imagePath: imageUrl, isSelected: isSelected),
            ),
            const SizedBox(height: 5),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryImage extends StatelessWidget {
  const _CategoryImage({required this.imagePath, required this.isSelected});

  final String imagePath;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final fallbackIcon = Icon(
      Icons.category_outlined,
      color: isSelected ? Colors.white : context.colors.textMuted,
    );

    final resolvedPath = cloudinaryUrlForAsset(imagePath);
    if (resolvedPath == null || resolvedPath.startsWith('assets/')) {
      return fallbackIcon;
    }

    return Image.network(
      resolvedPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallbackIcon,
    );
  }
}
