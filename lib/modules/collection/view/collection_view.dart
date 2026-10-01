import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/product_image.dart';
import '../../../data/models/category_model.dart';
import '../../cart/controller/cart_controller.dart';
import '../../home/widgets/product_card.dart';
import '../../wishlist/controller/wishlist_controller.dart';
import '../controller/collection_controller.dart';

class CollectionView extends GetView<CollectionController> {
  const CollectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistController = Get.find<WishlistController>();
    final cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        leading: Obx(
          () => controller.category == null
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: 'Collections',
                  onPressed: controller.showCategories,
                  icon: const Icon(Icons.arrow_back),
                ),
        ),
        title: Obx(
          () => Text(
            controller.category?.name ?? 'Collections',
            style: AppTextStyles.titleMedium,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          switch (controller.status.value) {
            case CollectionLoadStatus.idle:
            case CollectionLoadStatus.loading:
              return const AppLoadingState(message: 'Loading collection');
            case CollectionLoadStatus.error:
              return AppErrorState(
                message:
                    controller.errorMessage.value ??
                    'Collection could not be loaded.',
                onRetry: controller.category == null
                    ? controller.loadCategories
                    : controller.loadProducts,
              );
            case CollectionLoadStatus.empty:
              return AppEmptyState(
                title: controller.category == null
                    ? 'No collections yet'
                    : 'No products yet',
                message: controller.category == null
                    ? 'Collections will appear here once they are added.'
                    : '${controller.category?.name ?? 'This collection'} products will appear here.',
                icon: Icons.inventory_2_outlined,
              );
            case CollectionLoadStatus.success:
              if (controller.category == null) {
                return _CategoryBrowser(controller: controller);
              }

              return RefreshIndicator(
                onRefresh: controller.loadProducts,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 560 ? 3 : 2;
                    final cardWidth =
                        ((constraints.maxWidth -
                                    (AppLayout.pagePadding * 2) -
                                    ((crossAxisCount - 1) * 16)) /
                                crossAxisCount)
                            .clamp(150.0, 190.0)
                            .toDouble();

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppLayout.pagePadding,
                        16,
                        AppLayout.pagePadding,
                        32,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: cardWidth / (cardWidth * 1.9),
                      ),
                      itemCount: controller.products.length,
                      itemBuilder: (context, index) {
                        final product = controller.products[index];
                        return Obx(
                          () => ProductCard(
                            product: product,
                            width: cardWidth,
                            onTap: () => controller.openProduct(product),
                            isWishlisted: wishlistController.isWishlisted(
                              product.id,
                            ),
                            isInCart: cartController.isInCart(product.id),
                            onWishlistTap: () =>
                                wishlistController.toggleProduct(product),
                            onCartTap: () => cartController.addProduct(product),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
          }
        }),
      ),
    );
  }
}

class _CategoryBrowser extends StatelessWidget {
  const _CategoryBrowser({required this.controller});

  final CollectionController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.loadCategories,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 560 ? 3 : 2;

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppLayout.pagePadding,
              16,
              AppLayout.pagePadding,
              32,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return _CategoryTile(
                category: category,
                onTap: () => controller.selectCategory(category),
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final CategoryModel category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(
                child: Container(
                  width: 64,
                  height: 64,
                  color: Colors.white,
                  child: ProductImage(imageUrl: category.imageUrl),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
