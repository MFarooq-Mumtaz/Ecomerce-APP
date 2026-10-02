import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../data/models/product_model.dart';
import '../../cart/controller/cart_controller.dart';
import '../../home/widgets/product_card.dart';
import '../controller/wishlist_controller.dart';

class WishlistView extends GetView<WishlistController> {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        foregroundColor: context.colors.textPrimary,
        title: Obx(
          () => Text(
            'My Favourites (${controller.productIds.length})',
            style: AppTextStyles.titleMedium,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          switch (controller.status.value) {
            case WishlistLoadStatus.idle:
            case WishlistLoadStatus.loading:
              return const AppLoadingState(message: 'Loading wishlist');
            case WishlistLoadStatus.error:
              return AppErrorState(
                message:
                    controller.errorMessage.value ??
                    'Wishlist could not be loaded.',
                onRetry: controller.loadWishlist,
              );
            case WishlistLoadStatus.empty:
              return const AppEmptyState(
                title: 'Wishlist is empty',
                message: 'Tap the heart on a product to save it here.',
                icon: Icons.favorite_border,
              );
            case WishlistLoadStatus.success:
              return RefreshIndicator(
                onRefresh: controller.loadWishlist,
                child: ResponsiveBuilder(
                  builder: (context, layout) {
                    return GridView.builder(
                      padding: layout.pageInsets(
                        maxContentWidth: Responsive.gridMaxWidth,
                        top: 24,
                      ),
                      gridDelegate: ProductCard.gridDelegate(
                        layout,
                        MediaQuery.textScalerOf(context),
                      ),
                      itemCount: controller.products.length,
                      itemBuilder: (context, index) {
                        final product = controller.products[index];
                        return _WishlistProductCard(
                          product: product,
                          wishlistController: controller,
                          cartController: cartController,
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

class _WishlistProductCard extends StatelessWidget {
  const _WishlistProductCard({
    required this.product,
    required this.wishlistController,
    required this.cartController,
  });

  final ProductModel product;
  final WishlistController wishlistController;
  final CartController cartController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ProductCard(
        product: product,
        onTap: () => Get.toNamed(AppRoutes.productDetail, arguments: product),
        isWishlisted: wishlistController.isWishlisted(product.id),
        isInCart: cartController.isInCart(product.id),
        onWishlistTap: () => wishlistController.toggleProduct(product),
        onCartTap: () =>
            cartController.addProduct(product, openCartAfterAdd: true),
      ),
    );
  }
}
