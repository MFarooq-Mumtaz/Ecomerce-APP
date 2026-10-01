import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../controller/vendor_orders_controller.dart';
import '../widgets/vendor_order_card.dart';

class VendorOrdersView extends GetView<VendorOrdersController> {
  const VendorOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        foregroundColor: context.colors.textPrimary,
        title: Text('Orders', style: AppTextStyles.titleMedium),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          switch (controller.status.value) {
            case VendorOrdersStatus.idle:
            case VendorOrdersStatus.loading:
              return const AppLoadingState(message: 'Loading orders');
            case VendorOrdersStatus.error:
              return AppErrorState(
                message:
                    controller.errorMessage.value ??
                    'Orders could not be loaded.',
                onRetry: controller.loadOrders,
              );
            case VendorOrdersStatus.empty:
              return const AppEmptyState(
                title: 'No orders yet',
                message: 'Orders for your products will appear here.',
                icon: Icons.receipt_long_outlined,
              );
            case VendorOrdersStatus.success:
              return RefreshIndicator(
                onRefresh: controller.loadOrders,
                child: ResponsiveBuilder(
                  builder: (context, layout) => ListView.separated(
                    padding: layout.pageInsets(),
                    itemCount: controller.orders.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = controller.orders[index];
                      return VendorOrderCard(
                        order: order,
                        items: controller.itemsFor(order),
                      );
                    },
                  ),
                ),
              );
          }
        }),
      ),
    );
  }
}
