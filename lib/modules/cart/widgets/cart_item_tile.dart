import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/product_image_url.dart';
import '../../../core/widgets/product_image.dart';
import '../../../data/repositories/cart_repository.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
    super.key,
  });

  final CartProductItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The image grows a little on wide cards and shrinks on narrow ones.
          final imageSize = (constraints.maxWidth * 0.22).clamp(56.0, 96.0);
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox.square(
                    dimension: imageSize,
                    child: ProductImage(
                      imageUrl: productImageUrl(item.product),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '\$${item.product.price.toStringAsFixed(2)}',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _QuantityButton(
                            icon: Icons.remove,
                            onPressed: onDecrease,
                            tooltip: 'Decrease quantity',
                          ),
                          SizedBox(
                            width: 38,
                            child: Text(
                              item.quantity.toString(),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.titleMedium,
                            ),
                          ),
                          _QuantityButton(
                            icon: Icons.add,
                            onPressed: onIncrease,
                            tooltip: 'Increase quantity',
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: 'Remove item',
                            onPressed: onRemove,
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ],
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

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox.square(
        dimension: 32,
        child: IconButton.filledTonal(
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          icon: Icon(icon, size: 16),
        ),
      ),
    );
  }
}
