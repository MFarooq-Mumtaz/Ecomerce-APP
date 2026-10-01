import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/product_image.dart';
import '../../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    required this.width,
    required this.onTap,
    required this.isWishlisted,
    required this.isInCart,
    required this.onWishlistTap,
    required this.onCartTap,
    super.key,
  });

  final ProductModel product;
  final double width;
  final VoidCallback onTap;
  final bool isWishlisted;
  final bool isInCart;
  final VoidCallback onWishlistTap;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 159 / 220,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ProductImage(
                      imageUrl: product.imageUrl,
                      localImagePath: product.localImagePath,
                    ),
                    Positioned(
                      top: 5,
                      right: 8,
                      child: _CircleActionButton(
                        tooltip: isWishlisted
                            ? 'Remove from wishlist'
                            : 'Add to wishlist',
                        icon: isWishlisted
                            ? Icons.favorite
                            : Icons.favorite_border,
                        onTap: onWishlistTap,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                _formatPrice(product.price),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (product.compareAtPrice != null) ...[
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    _formatPrice(product.compareAtPrice!),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textMuted,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        _CartButton(isInCart: isInCart, onTap: onCartTap),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(double value) => '\$${value.toStringAsFixed(2)}';
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.82),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 28,
            height: 28,
            child: Icon(icon, size: 18, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton({required this.isInCart, required this.onTap});

  final bool isInCart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isInCart ? 'Add one more' : 'Add to cart',
      child: Material(
        color: isInCart ? AppColors.primary : AppColors.textPrimary,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: const SizedBox(
            width: 24,
            height: 24,
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
