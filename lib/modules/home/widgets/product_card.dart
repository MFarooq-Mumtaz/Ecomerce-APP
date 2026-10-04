import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/product_image_url.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/product_image.dart';
import '../../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    required this.onTap,
    required this.isWishlisted,
    required this.isInCart,
    required this.onWishlistTap,
    required this.onCartTap,
    super.key,
    this.width,
  });

  /// Product cards now use a near-square media area so Cloudinary product
  /// photos and transparent PNG marks are visible without tall cropping.
  static const imageAspectRatio = 1.04;

  /// Height a card needs at [width], including the name/price area for the
  /// current text scale. Grids and horizontal lists use this so a card
  /// never overflows, on any screen or font size.
  static double heightFor(double width, TextScaler textScaler) {
    final lineHeight =
        textScaler.scale(AppTextStyles.bodyMedium.fontSize!) *
        AppTextStyles.bodyMedium.height!;
    final vendorLineHeight =
        textScaler.scale(AppTextStyles.bodyMedium.fontSize! - 1) *
        AppTextStyles.bodyMedium.height!;
    final infoHeight =
        8 +
        lineHeight +
        3 +
        vendorLineHeight +
        6 +
        math.max(24, lineHeight) +
        12;
    return (width / imageAspectRatio) + infoHeight + 2;
  }

  /// Grid layout for product cards: phones get 2 columns, wider screens get
  /// more, and every row is tall enough for the card at that width.
  static SliverGridDelegate gridDelegate(
    Responsive layout,
    TextScaler textScaler, {
    double spacing = 16,
  }) {
    final columns = layout.columnsFor(
      minItemWidth: layout.isCompact ? 136 : 160,
      spacing: spacing,
      minColumns: 2,
    );
    final itemWidth = layout.itemWidth(columns: columns, spacing: spacing);
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      mainAxisExtent: heightFor(itemWidth, textScaler),
    );
  }

  final ProductModel product;

  /// Fixed width for horizontal lists; null fills the parent (grids).
  final double? width;
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
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The image takes whatever height is left after the text, so
              // the card fits the exact size its parent gives it.
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ProductImage(imageUrl: productImageUrl(product)),
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
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _vendorLabel(product),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.colors.textMuted,
                        fontSize: AppTextStyles.bodyMedium.fontSize! - 1,
                        fontWeight: FontWeight.w600,
                      ),
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
                                      color: context.colors.textMuted,
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

  String _vendorLabel(ProductModel product) {
    final vendorName = product.vendorName?.trim();
    if (vendorName != null && vendorName.isNotEmpty) {
      return vendorName;
    }

    return 'Vendor name pending';
  }
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
            // The circle is always light, so the icon stays dark in both
            // theme modes.
            child: Icon(icon, size: 18, color: AppPalette.light.textPrimary),
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
        color: isInCart ? AppColors.primary : context.colors.textPrimary,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: SizedBox(
            width: 24,
            height: 24,
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 16,
              // Contrasts with the button color in light and dark mode.
              color: isInCart ? Colors.white : context.colors.background,
            ),
          ),
        ),
      ),
    );
  }
}
