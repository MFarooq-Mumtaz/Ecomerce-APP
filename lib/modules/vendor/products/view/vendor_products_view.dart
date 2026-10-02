import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../controller/vendor_products_controller.dart';
import '../widgets/vendor_product_item.dart';

class VendorProductsView extends GetView<VendorProductsController> {
  const VendorProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        foregroundColor: context.colors.textPrimary,
        title: Text('My Products', style: AppTextStyles.titleMedium),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Add product',
            onPressed: controller.addProduct,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          switch (controller.status.value) {
            case VendorProductsStatus.idle:
            case VendorProductsStatus.loading:
              return const AppLoadingState(message: 'Loading products');
            case VendorProductsStatus.error:
              return AppErrorState(
                message:
                    controller.errorMessage.value ??
                    'Products could not be loaded.',
                onRetry: controller.loadProducts,
              );
            case VendorProductsStatus.empty:
              return AppEmptyState(
                title: 'No products yet',
                message: 'Add your first product to start selling on MIRA.',
                icon: Icons.inventory_2_outlined,
              );
            case VendorProductsStatus.success:
              return RefreshIndicator(
                onRefresh: controller.loadProducts,
                child: ResponsiveBuilder(
                  builder: (context, layout) {
                    return ListView.separated(
                      // Extra bottom space so the add button never covers
                      // the last product.
                      padding: layout.pageInsets(bottom: 96),
                      itemCount: controller.products.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final product = controller.products[index];
                        return Obx(
                          () => VendorProductItem(
                            product: product,
                            isDeleting: controller.deletingProductIds.contains(
                              product.id,
                            ),
                            onEdit: () => controller.editProduct(product),
                            onDelete: () => controller.confirmDelete(product),
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
      floatingActionButton: FloatingActionButton(
        onPressed: controller.addProduct,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
