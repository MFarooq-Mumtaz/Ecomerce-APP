import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/product_image_url.dart';
import '../../../../core/widgets/product_image.dart';
import '../../../../data/models/product_model.dart';

class VendorProductItem extends StatelessWidget {
  const VendorProductItem({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.isDeleting,
    super.key,
  });

  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Narrow cards: smaller image and one menu instead of two buttons.
          final isNarrow = constraints.maxWidth < 330;
          final imageSize = isNarrow ? 56.0 : 72.0;
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: imageSize,
                    height: imageSize,
                    color: Colors.white,
                    child: ProductImage(imageUrl: productImageUrl(product)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${product.price.toStringAsFixed(2)} • Stock ${product.stock ?? 0}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: context.colors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _StatusChip(isActive: product.isActive),
                    ],
                  ),
                ),
                if (isNarrow)
                  _ActionsMenu(
                    isDeleting: isDeleting,
                    onEdit: onEdit,
                    onDelete: onDelete,
                  )
                else ...[
                  IconButton(
                    tooltip: 'Edit product',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'Delete product',
                    onPressed: isDeleting ? null : onDelete,
                    icon: isDeleting
                        ? const _DeletingIndicator()
                        : const Icon(Icons.delete_outline),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ActionsMenu extends StatelessWidget {
  const _ActionsMenu({
    required this.isDeleting,
    required this.onEdit,
    required this.onDelete,
  });

  final bool isDeleting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    if (isDeleting) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: _DeletingIndicator(),
      );
    }

    return PopupMenuButton<VoidCallback>(
      tooltip: 'Product actions',
      onSelected: (action) => action(),
      itemBuilder: (context) => [
        PopupMenuItem(value: onEdit, child: const Text('Edit')),
        PopupMenuItem(value: onDelete, child: const Text('Delete')),
      ],
    );
  }
}

class _DeletingIndicator extends StatelessWidget {
  const _DeletingIndicator();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: 18,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : context.colors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: AppTextStyles.bodyMedium.copyWith(color: color),
      ),
    );
  }
}
