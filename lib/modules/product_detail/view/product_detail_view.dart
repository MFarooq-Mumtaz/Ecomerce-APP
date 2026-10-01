import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/product_image.dart';
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
        backgroundColor: AppColors.background,
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.background,
              foregroundColor: AppColors.textPrimary,
              title: Text(product.name, style: AppTextStyles.titleMedium),
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
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppLayout.pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ProductImage(
                          imageUrl: product.imageUrl,
                          localImagePath: product.localImagePath,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(product.name, style: AppTextStyles.titleLarge),
                    const SizedBox(height: 8),
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
                          color: AppColors.textMuted,
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
                              : () => cartController.addProduct(product),
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
                              ? AppColors.textMuted
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
