import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_layout.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/unfocus_on_tap.dart';
import '../../../data/models/address_model.dart';
import '../../../data/repositories/cart_repository.dart';
import '../controller/checkout_controller.dart';
import '../widgets/checkout_summary.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return UnfocusOnTap(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          title: Text('Checkout', style: AppTextStyles.titleMedium),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Obx(() {
            switch (controller.status.value) {
              case CheckoutLoadStatus.idle:
              case CheckoutLoadStatus.loading:
                return const AppLoadingState(message: 'Loading checkout');
              case CheckoutLoadStatus.error:
                return AppErrorState(
                  message:
                      controller.errorMessage.value ??
                      'Checkout could not be loaded.',
                  onRetry: controller.loadCheckout,
                );
              case CheckoutLoadStatus.success:
                return Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: controller.loadCheckout,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                          children: [
                            _SectionTitle(
                              title: 'Order Items',
                              trailing: '${controller.itemCount} item(s)',
                            ),
                            const SizedBox(height: 12),
                            ...controller.cartItems.map(
                              (item) => _CheckoutItemRow(item: item),
                            ),
                            const SizedBox(height: 24),
                            _AddressSection(controller: controller),
                            const SizedBox(height: 24),
                            const _PaymentMethodSection(),
                          ],
                        ),
                      ),
                    ),
                    Obx(
                      () => CheckoutSummary(
                        subtotal: controller.subtotal,
                        shipping: controller.shipping,
                        total: controller.total,
                        isPlacingOrder: controller.isPlacingOrder.value,
                        onPlaceOrder: controller.placeOrder,
                      ),
                    ),
                  ],
                );
            }
          }),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.titleMedium),
        const Spacer(),
        if (trailing != null)
          Text(
            trailing!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
      ],
    );
  }
}

class _CheckoutItemRow extends StatelessWidget {
  const _CheckoutItemRow({required this.item});

  final CartProductItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          title: Text(
            item.product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleMedium,
          ),
          subtitle: Text(
            '${item.quantity} x \$${item.product.price.toStringAsFixed(2)}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          trailing: Text(
            '\$${item.lineTotal.toStringAsFixed(2)}',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class _AddressSection extends StatelessWidget {
  const _AddressSection({required this.controller});

  final CheckoutController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Delivery Address',
            trailing: controller.addresses.isEmpty ? null : 'Change',
          ),
          const SizedBox(height: 12),
          if (controller.addresses.isNotEmpty)
            ...controller.addresses.map(
              (address) => _AddressCard(
                address: address,
                isSelected: controller.selectedAddressId.value == address.id,
                onTap: () => controller.selectAddress(address),
              ),
            ),
          if (controller.showAddressForm.value) ...[
            const SizedBox(height: 12),
            _AddressForm(controller: controller),
          ],
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: controller.toggleAddressForm,
            icon: Icon(
              controller.showAddressForm.value ? Icons.close : Icons.add,
            ),
            label: Text(
              controller.showAddressForm.value
                  ? 'Hide address form'
                  : 'Add address',
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  final AddressModel address;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          onTap: onTap,
          leading: Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: isSelected ? AppColors.primary : AppColors.textMuted,
          ),
          title: Text(address.fullName, style: AppTextStyles.titleMedium),
          subtitle: Text(
            address.summary,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _AddressForm extends StatelessWidget {
  const _AddressForm({required this.controller});

  final CheckoutController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Input(controller: controller.fullNameController, label: 'Full name'),
        _Input(controller: controller.phoneController, label: 'Phone'),
        _Input(
          controller: controller.addressLine1Controller,
          label: 'Address line 1',
        ),
        _Input(
          controller: controller.addressLine2Controller,
          label: 'Address line 2',
        ),
        Row(
          children: [
            Expanded(
              child: _Input(
                controller: controller.cityController,
                label: 'City',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Input(
                controller: controller.stateController,
                label: 'State',
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _Input(
                controller: controller.postalCodeController,
                label: 'Postal code',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Input(
                controller: controller.countryController,
                label: 'Country',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: AppLayout.buttonHeight,
          child: Obx(
            () => FilledButton(
              onPressed: controller.isSavingAddress.value
                  ? null
                  : controller.saveAddress,
              child: controller.isSavingAddress.value
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Address'),
            ),
          ),
        ),
      ],
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class _PaymentMethodSection extends StatelessWidget {
  const _PaymentMethodSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Payment Method'),
        const SizedBox(height: 12),
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          child: ListTile(
            onTap: () => Get.toNamed(AppRoutes.paymentMethod),
            leading: const Icon(Icons.payments_outlined),
            title: Text('Payment Method', style: AppTextStyles.titleMedium),
            subtitle: Text(
              'Payment integration will be added later.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ],
    );
  }
}
