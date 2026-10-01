import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../cart/controller/cart_controller.dart';
import '../../cart/view/cart_view.dart';
import '../../collection/view/collection_view.dart';
import '../../home/view/home_view.dart';
import '../../profile/view/profile_view.dart';
import '../controller/app_shell_controller.dart';

class AppShellView extends GetView<AppShellController> {
  const AppShellView({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: controller.selectedIndex.value,
          children: const [
            HomeView(),
            CollectionView(),
            CartView(),
            ProfileView(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: controller.selectTab,
          backgroundColor: AppColors.background,
          indicatorColor: AppColors.primary.withValues(alpha: 0.12),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view),
              label: 'Collections',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: cartController.itemCount > 0,
                label: Text(cartController.itemCount.toString()),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: cartController.itemCount > 0,
                label: Text(cartController.itemCount.toString()),
                child: const Icon(Icons.shopping_bag),
              ),
              label: 'Cart',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
