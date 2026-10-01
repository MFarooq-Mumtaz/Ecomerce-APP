import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_layout.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_state_views.dart';
import '../controller/cart_controller.dart';
import '../widgets/cart_item_tile.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: Obx(
          () => Text(
            'Cart (${controller.itemCount})',
            style: AppTextStyles.titleMedium,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          switch (controller.status.value) {
            case CartLoadStatus.idle:
            case CartLoadStatus.loading:
              return const AppLoadingState(message: 'Loading cart');
            case CartLoadStatus.error:
              return AppErrorState(
                message:
                    controller.errorMessage.value ??
                    'Cart could not be loaded.',
                onRetry: controller.loadCart,
              );
            case CartLoadStatus.empty:
              return const AppEmptyState(
                title: 'Cart is empty',
                message: 'Add products to your cart before checkout.',
                icon: Icons.shopping_bag_outlined,
              );
            case CartLoadStatus.success:
              return Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: controller.loadCart,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppLayout.pagePadding,
                          24,
                          AppLayout.pagePadding,
                          24,
                        ),
                        itemCount: controller.items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = controller.items[index];
                          return CartItemTile(
                            item: item,
                            onIncrease: () => controller.increaseQuantity(item),
                            onDecrease: () => controller.decreaseQuantity(item),
                            onRemove: () =>
                                controller.removeProduct(item.product),
                          );
                        },
                      ),
                    ),
                  ),
                  _CartSummary(controller: controller),
                ],
              );
          }
        }),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.controller});

  final CartController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.surface)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Subtotal',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Obx(
                  () => Text(
                    '\$${controller.subtotal.toStringAsFixed(2)}',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => Get.toNamed(AppRoutes.checkout),
                child: const Text('Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
