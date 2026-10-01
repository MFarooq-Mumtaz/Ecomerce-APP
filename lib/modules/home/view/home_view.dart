import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/avero_logo.dart';
import '../../../data/models/product_model.dart';
import '../../cart/controller/cart_controller.dart';
import '../../wishlist/controller/wishlist_controller.dart';
import '../controller/home_controller.dart';
import '../widgets/category_item.dart';
import '../widgets/home_search_field.dart';
import '../widgets/home_section_header.dart';
import '../widgets/product_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ResponsiveBuilder(
        builder: (context, layout) {
          final horizontalPadding = layout.horizontalPadding(
            Responsive.gridMaxWidth,
          );
          // Phones show 2 cards per row width, tablets show more.
          final visibleCards = layout.columnsFor(
            minItemWidth: layout.isCompact ? 136 : 170,
            spacing: 12,
            minColumns: 2,
          );
          final cardWidth = layout.itemWidth(
            columns: visibleCards,
            spacing: 12,
          );
          // Landscape phones have little height, so the header moves up.
          final topPadding = layout.height < 560 ? 16.0 : 44.0;

          return Obx(
            () => RefreshIndicator(
              onRefresh: controller.refreshHome,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      topPadding,
                      horizontalPadding,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _HomeHeader(
                        searchHasQuery: controller.searchQuery.isNotEmpty,
                      ),
                    ),
                  ),
                  if (controller.status.value == HomeLoadStatus.loading)
                    const SliverFillRemaining(
                      child: AppLoadingState(message: 'Loading home'),
                    )
                  else if (controller.status.value == HomeLoadStatus.error)
                    SliverFillRemaining(
                      child: AppErrorState(
                        message:
                            controller.errorMessage.value ??
                            'Home data could not be loaded.',
                        onRetry: controller.loadHome,
                      ),
                    )
                  else if (controller.status.value == HomeLoadStatus.empty)
                    const SliverFillRemaining(
                      child: AppEmptyState(
                        title: 'No catalog yet',
                        message:
                            'Products and categories will appear here once they are added in Firestore.',
                      ),
                    )
                  else ...[
                    if (controller.categories.isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          24,
                          horizontalPadding,
                          0,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: _CategoriesSection(controller: controller),
                        ),
                      ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        24,
                        horizontalPadding,
                        32,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: controller.isSearching
                            ? _ProductSection(
                                title: 'Search Results',
                                products: controller.searchResults,
                                emptyMessage: 'No matching products found.',
                                cardWidth: cardWidth,
                                onProductTap: controller.openProduct,
                              )
                            : _ProductSection(
                                title: 'Top Selling',
                                products: controller.topSellingProducts,
                                emptyMessage:
                                    'Best sellers will appear here once '
                                    'orders are placed.',
                                cardWidth: cardWidth,
                                onProductTap: controller.openProduct,
                                onSeeAll: controller.openTopSelling,
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeHeader extends GetView<HomeController> {
  const _HomeHeader({required this.searchHasQuery});

  final bool searchHasQuery;

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Column(
      children: [
        Row(
          children: [
            const AveroLogo(size: 40),
            const Spacer(),
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Men',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, size: 16),
                ],
              ),
            ),
            const Spacer(),
            Obx(
              () => IconButton.filled(
                tooltip: 'Cart',
                onPressed: () => Get.toNamed(AppRoutes.cart),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                icon: Badge(
                  isLabelVisible: cartController.itemCount > 0,
                  label: Text(cartController.itemCount.toString()),
                  child: const Icon(Icons.shopping_bag_outlined, size: 18),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        HomeSearchField(
          controller: controller.searchController,
          onChanged: controller.updateSearch,
          onClear: controller.clearSearch,
          hasQuery: searchHasQuery,
        ),
      ],
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          title: 'Categories',
          onSeeAll: controller.openAllCategories,
        ),
        const SizedBox(height: 14),
        SizedBox(
          // Circle (56) + gap + one label line at the current font size.
          height: 66 + MediaQuery.textScalerOf(context).scale(20),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 4),
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return CategoryItem(
                category: category,
                isSelected: false,
                onTap: () => controller.openCategory(category),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProductSection extends StatelessWidget {
  const _ProductSection({
    required this.title,
    required this.products,
    required this.cardWidth,
    required this.onProductTap,
    required this.emptyMessage,
    this.onSeeAll,
  });

  final String title;
  final List<ProductModel> products;
  final String emptyMessage;
  final double cardWidth;
  final ValueChanged<ProductModel> onProductTap;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final wishlistController = Get.find<WishlistController>();
    final cartController = Get.find<CartController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(title: title, onSeeAll: onSeeAll),
        const SizedBox(height: 14),
        if (products.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              emptyMessage,
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.colors.textMuted,
              ),
            ),
          )
        else
          SizedBox(
            height: ProductCard.heightFor(
              cardWidth,
              MediaQuery.textScalerOf(context),
            ),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = products[index];
                return Obx(
                  () => ProductCard(
                    product: product,
                    width: cardWidth,
                    onTap: () => onProductTap(product),
                    isWishlisted: wishlistController.isWishlisted(product.id),
                    isInCart: cartController.isInCart(product.id),
                    onWishlistTap: () =>
                        wishlistController.toggleProduct(product),
                    onCartTap: () => cartController.addProduct(product),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
