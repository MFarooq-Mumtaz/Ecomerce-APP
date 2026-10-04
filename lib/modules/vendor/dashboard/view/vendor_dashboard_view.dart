import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../controller/vendor_dashboard_controller.dart';

class VendorDashboardView extends GetView<VendorDashboardController> {
  const VendorDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        foregroundColor: context.colors.textPrimary,
        title: Text('Manage Store', style: AppTextStyles.titleMedium),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          switch (controller.status.value) {
            case VendorDashboardStatus.idle:
            case VendorDashboardStatus.loading:
              return const AppLoadingState(message: 'Loading store');
            case VendorDashboardStatus.error:
              return AppErrorState(
                message:
                    controller.errorMessage.value ??
                    'Vendor dashboard could not be loaded.',
                onRetry: controller.loadDashboard,
              );
            case VendorDashboardStatus.success:
              final vendor = controller.vendor.value;
              return RefreshIndicator(
                onRefresh: controller.loadDashboard,
                child: ResponsiveBuilder(
                  builder: (context, layout) {
                    final maxContentWidth = layout.isExpanded
                        ? Responsive.gridMaxWidth
                        : Responsive.listMaxWidth;
                    return ListView(
                      padding: layout.pageInsets(
                        maxContentWidth: maxContentWidth,
                      ),
                      children: [
                        Text(
                          vendor?.storeName ?? 'My Store',
                          style: AppTextStyles.titleLarge,
                        ),
                        if (vendor != null &&
                            vendor.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            vendor.description,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: context.colors.textMuted,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        _ResponsiveWrap(
                          minItemWidth: MediaQuery.textScalerOf(
                            context,
                          ).scale(88),
                          maxColumns: 3,
                          children: [
                            _StatTile(
                              label: 'Products',
                              value: controller.productCount.value,
                            ),
                            _StatTile(
                              label: 'Orders',
                              value: controller.totalOrders.value,
                            ),
                            _StatTile(
                              label: 'Units Sold',
                              value: controller.unitsSold.value,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _ResponsiveWrap(
                          minItemWidth: 320,
                          maxColumns: 3,
                          children: [
                            _DashboardAction(
                              icon: Icons.inventory_2_outlined,
                              title: 'My Products',
                              subtitle: 'View, edit, or delete store products',
                              onTap: controller.openProducts,
                            ),
                            _DashboardAction(
                              icon: Icons.add_box_outlined,
                              title: 'Add Product',
                              subtitle: 'Create a new product in the catalog',
                              onTap: controller.addProduct,
                            ),
                            _DashboardAction(
                              icon: Icons.receipt_long_outlined,
                              title: 'Orders',
                              subtitle: 'Orders that include your products',
                              onTap: controller.openOrders,
                            ),
                          ],
                        ),
                      ],
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

/// Lays children out in as many equal columns as fit (up to [maxColumns]).
/// A last item that would sit alone in its row stretches to full width.
class _ResponsiveWrap extends StatelessWidget {
  const _ResponsiveWrap({
    required this.children,
    required this.minItemWidth,
    this.maxColumns = 3,
  });

  final List<Widget> children;
  final double minItemWidth;
  final int maxColumns;

  static const _spacing = 12.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = ((width + _spacing) / (minItemWidth + _spacing))
            .floor()
            .clamp(1, maxColumns);
        final itemWidth = (width - (_spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: _spacing,
          runSpacing: _spacing,
          children: [
            for (var index = 0; index < children.length; index += 1)
              SizedBox(
                width:
                    index == children.length - 1 &&
                        children.length % columns == 1 &&
                        columns > 1
                    ? width
                    : itemWidth,
                child: children[index],
              ),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value.toString(),
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: context.colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardAction extends StatelessWidget {
  const _DashboardAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: context.colors.background,
          foregroundColor: AppColors.primary,
          child: Icon(icon),
        ),
        title: Text(title, style: AppTextStyles.titleMedium),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: context.colors.textMuted,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
