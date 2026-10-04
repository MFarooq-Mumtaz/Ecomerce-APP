import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/product_image_url.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/product_image.dart';
import '../../../data/models/product_model.dart';
import '../../cart/controller/cart_controller.dart';
import '../../wishlist/controller/wishlist_controller.dart';
import '../controller/product_detail_controller.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final product = controller.product;
    if (product == null) {
      return Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(),
        body: const AppEmptyState(
          title: 'Product unavailable',
          message: 'This product could not be opened.',
        ),
      );
    }
    final wishlistController = Get.find<WishlistController>();
    final cartController = Get.find<CartController>();
    final isOutOfStock = product.stock != null && product.stock! <= 0;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: context.colors.background,
              foregroundColor: context.colors.textPrimary,
              title: Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleMedium,
              ),
              actions: [
                Obx(
                  () => IconButton(
                    tooltip: wishlistController.isWishlisted(product.id)
                        ? 'Remove from wishlist'
                        : 'Add to wishlist',
                    onPressed: () => wishlistController.toggleProduct(product),
                    icon: Icon(
                      wishlistController.isWishlisted(product.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: wishlistController.isWishlisted(product.id)
                          ? AppColors.primary
                          : context.colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: ResponsiveBuilder(
                builder: (context, layout) {
                  final image = ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ProductImage(imageUrl: productImageUrl(product)),
                    ),
                  );
                  final details = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: AppTextStyles.titleLarge),
                      const SizedBox(height: 8),
                      _VendorName(product: product),
                      const SizedBox(height: 12),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      if (product.categoryName != null &&
                          product.categoryName!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          product.categoryName!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: context.colors.textMuted,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text('Description', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        product.description.trim().isEmpty
                            ? 'No product description has been added yet.'
                            : product.description,
                        style: AppTextStyles.bodyLarge,
                      ),
                      const SizedBox(height: 32),
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: AppLayout.buttonHeight,
                          child: FilledButton.icon(
                            onPressed: isOutOfStock
                                ? null
                                : () => cartController.addProduct(
                                    product,
                                    openCartAfterAdd: true,
                                  ),
                            icon: const Icon(Icons.shopping_bag_outlined),
                            label: Text(
                              isOutOfStock
                                  ? 'Out of Stock'
                                  : cartController.isInCart(product.id)
                                  ? 'Add One More'
                                  : 'Add to Cart',
                            ),
                          ),
                        ),
                      ),
                      if (product.stock != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          product.stock! > 0
                              ? '${product.stock} item(s) available'
                              : 'Out of stock',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: product.stock! > 0
                                ? context.colors.textMuted
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ],
                  );

                  // Phones: image on top. Tablets/landscape: side by side.
                  if (layout.isCompact) {
                    return Padding(
                      padding: layout.pageInsets(
                        maxContentWidth: Responsive.formMaxWidth,
                        top: layout.pagePadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [image, const SizedBox(height: 24), details],
                      ),
                    );
                  }

                  return Padding(
                    padding: layout.pageInsets(
                      maxContentWidth: Responsive.gridMaxWidth,
                      top: layout.pagePadding,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: image),
                        SizedBox(width: layout.pagePadding),
                        Expanded(child: details),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorName extends StatelessWidget {
  const _VendorName({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final vendorName = product.vendorName?.trim();
    final label = vendorName == null || vendorName.isEmpty
        ? 'Vendor name pending'
        : vendorName;

    return Row(
      children: [
        Icon(
          Icons.storefront_outlined,
          size: 16,
          color: context.colors.textMuted,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Sold by $label',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: context.colors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
