import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../cart/controller/cart_controller.dart';
import '../../cart/view/cart_view.dart';
import '../../collection/view/collection_view.dart';
import '../../home/view/home_view.dart';
import '../../profile/view/profile_view.dart';
import '../controller/app_shell_controller.dart';

class AppShellView extends GetView<AppShellController> {
  const AppShellView({super.key});

  static const _tabs = [
    HomeView(),
    CollectionView(),
    CartView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return ResponsiveBuilder(
      builder: (context, layout) {
        return Obx(() {
          final selectedIndex = controller.selectedIndex.value;
          final cartCount = cartController.itemCount;
          final body = IndexedStack(index: selectedIndex, children: _tabs);

          // Phones: bottom navigation bar.
          if (layout.isCompact) {
            return Scaffold(
              backgroundColor: context.colors.background,
              body: body,
              bottomNavigationBar: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: controller.selectTab,
                backgroundColor: context.colors.background,
                indicatorColor: AppColors.primary.withValues(alpha: 0.12),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                destinations: [
                  for (final tab in _ShellTab.values)
                    NavigationDestination(
                      icon: tab.icon(cartCount, selected: false),
                      selectedIcon: tab.icon(cartCount, selected: true),
                      label: tab.label,
                    ),
                ],
              ),
            );
          }

          // Tablets and landscape: side navigation rail.
          return Scaffold(
            backgroundColor: context.colors.background,
            body: SafeArea(
              right: false,
              child: Row(
                children: [
                  NavigationRail(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: controller.selectTab,
                    backgroundColor: context.colors.background,
                    indicatorColor: AppColors.primary.withValues(alpha: 0.12),
                    extended: layout.isExpanded,
                    labelType: layout.isExpanded
                        ? NavigationRailLabelType.none
                        : NavigationRailLabelType.all,
                    selectedLabelTextStyle: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                    unselectedLabelTextStyle: AppTextStyles.bodyMedium,
                    groupAlignment: -0.9,
                    destinations: [
                      for (final tab in _ShellTab.values)
                        NavigationRailDestination(
                          icon: tab.icon(cartCount, selected: false),
                          selectedIcon: tab.icon(cartCount, selected: true),
                          label: Text(tab.label),
                        ),
                    ],
                  ),
                  VerticalDivider(width: 1, color: context.colors.surface),
                  Expanded(child: body),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

enum _ShellTab {
  home('Home', Icons.home_outlined, Icons.home),
  collections('Collections', Icons.grid_view_outlined, Icons.grid_view),
  cart('Cart', Icons.shopping_bag_outlined, Icons.shopping_bag),
  profile('Profile', Icons.person_outline, Icons.person);

  const _ShellTab(this.label, this.outlinedIcon, this.filledIcon);

  final String label;
  final IconData outlinedIcon;
  final IconData filledIcon;

  Widget icon(int cartCount, {required bool selected}) {
    final iconWidget = Icon(selected ? filledIcon : outlinedIcon);
    if (this != _ShellTab.cart) {
      return iconWidget;
    }
    return Badge(
      isLabelVisible: cartCount > 0,
      label: Text(cartCount.toString()),
      child: iconWidget,
    );
  }
}
