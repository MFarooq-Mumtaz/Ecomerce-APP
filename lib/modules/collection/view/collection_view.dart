import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
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
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        foregroundColor: context.colors.textPrimary,
        leading: Obx(
          () => !controller.isShowingProducts
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: 'Collections',
                  onPressed: controller.showCategories,
                  icon: const Icon(Icons.arrow_back),
                ),
        ),
        title: Obx(
          () => Text(controller.title, style: AppTextStyles.titleMedium),
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
                onRetry: controller.isShowingProducts
                    ? controller.loadProducts
                    : controller.loadCategories,
              );
            case CollectionLoadStatus.empty:
              return AppEmptyState(
                title: !controller.isShowingProducts
                    ? 'No collections yet'
                    : controller.isTopSelling.value
                    ? 'No best sellers yet'
                    : 'No products yet',
                message: !controller.isShowingProducts
                    ? 'Collections will appear here once they are added.'
                    : controller.isTopSelling.value
                    ? 'Best sellers will appear here once orders are placed.'
                    : '${controller.title} products will appear here.',
                icon: Icons.inventory_2_outlined,
              );
            case CollectionLoadStatus.success:
              if (!controller.isShowingProducts) {
                return _CategoryBrowser(controller: controller);
              }

              return RefreshIndicator(
                onRefresh: controller.loadProducts,
                child: ResponsiveBuilder(
                  builder: (context, layout) {
                    return GridView.builder(
                      padding: layout.pageInsets(
                        maxContentWidth: Responsive.gridMaxWidth,
                      ),
                      gridDelegate: ProductCard.gridDelegate(
                        layout,
                        MediaQuery.textScalerOf(context),
                      ),
                      itemCount: controller.products.length,
                      itemBuilder: (context, index) {
                        final product = controller.products[index];
                        return Obx(
                          () => ProductCard(
                            product: product,
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
      child: ResponsiveBuilder(
        builder: (context, layout) {
          final textScaler = MediaQuery.textScalerOf(context);
          return GridView.builder(
            padding: layout.pageInsets(
              maxContentWidth: Responsive.gridMaxWidth,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: layout.columnsFor(
                minItemWidth: 136,
                minColumns: 2,
              ),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              // Image (64) + paddings + one 16px title line (with its line
              // height) at the current font scale.
              mainAxisExtent: 100 + textScaler.scale(16) * 1.6,
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
      color: context.colors.surface,
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
