import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../controller/vendor_dashboard_controller.dart';

class VendorDashboardView extends GetView<VendorDashboardController> {
  const VendorDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
              return LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding = constraints.maxWidth > 600
                      ? 32.0
                      : AppLayout.pagePadding;

                  return ListView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      32,
                      horizontalPadding,
                      32,
                    ),
                    children: [
                      Text(
                        vendor?.storeName ?? 'Vendor Dashboard',
                        style: AppTextStyles.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        vendor?.description ?? 'Manage your Avero store.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _DashboardAction(
                        icon: Icons.inventory_2_outlined,
                        title: 'My Products',
                        subtitle: 'View, edit, or delete store products',
                        onTap: controller.openProducts,
                      ),
                      const SizedBox(height: 12),
                      _DashboardAction(
                        icon: Icons.add_box_outlined,
                        title: 'Add Product',
                        subtitle: 'Create a new product in the catalog',
                        onTap: controller.addProduct,
                      ),
                      const SizedBox(height: 12),
                      _DashboardAction(
                        icon: Icons.storefront_outlined,
                        title: 'Browse Customer App',
                        subtitle: 'Open the customer shopping experience',
                        onTap: controller.browseCustomerApp,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: AppLayout.buttonHeight,
                        child: Obx(
                          () => OutlinedButton.icon(
                            onPressed: controller.isLoggingOut.value
                                ? null
                                : controller.logout,
                            icon: controller.isLoggingOut.value
                                ? const SizedBox.square(
                                    dimension: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.logout),
                            label: const Text('Logout'),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
          }
        }),
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
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          child: Icon(icon),
        ),
        title: Text(title, style: AppTextStyles.titleMedium),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
