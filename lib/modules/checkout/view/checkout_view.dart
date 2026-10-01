import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/phone_number_field.dart';
import '../../../core/widgets/responsive_field_pair.dart';
import '../../../data/models/address_model.dart';
import '../../../data/repositories/cart_repository.dart';
import '../controller/checkout_controller.dart';
import '../widgets/checkout_summary.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        foregroundColor: context.colors.textPrimary,
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
              return ResponsiveBuilder(
                builder: (context, layout) {
                  Widget details(EdgeInsets padding) {
                    return RefreshIndicator(
                      onRefresh: controller.loadCheckout,
                      child: ListView(
                        padding: padding,
                        children: [
                          _AddressSection(controller: controller),
                          const SizedBox(height: 24),
                          _SectionTitle(
                            title: 'Order Summary',
                            trailing: '${controller.itemCount} item(s)',
                          ),
                          const SizedBox(height: 12),
                          ...controller.cartItems.map(
                            (item) => _CheckoutItemRow(item: item),
                          ),
                        ],
                      ),
                    );
                  }

                  final summary = Obx(
                    () => CheckoutSummary(
                      subtotal: controller.subtotal,
                      total: controller.total,
                      isPlacingOrder: controller.isPlacingOrder.value,
                      onPlaceOrder: controller.placeOrder,
                    ),
                  );

                  // Wide screens: details on the left, summary on the right.
                  if (layout.isExpanded) {
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: Responsive.gridMaxWidth,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: details(
                                EdgeInsets.fromLTRB(
                                  layout.pagePadding,
                                  16,
                                  16,
                                  24,
                                ),
                              ),
                            ),
                            SizedBox(width: 400, child: summary),
                          ],
                        ),
                      ),
                    );
                  }

                  // Phones and small tablets: one column, summary at bottom.
                  return Column(
                    children: [
                      Expanded(child: details(layout.pageInsets(bottom: 24))),
                      summary,
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
              color: context.colors.textMuted,
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
        color: context.colors.surface,
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
              color: context.colors.textMuted,
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
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          onTap: onTap,
          leading: Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: isSelected ? AppColors.primary : context.colors.textMuted,
          ),
          title: Text(address.fullName, style: AppTextStyles.titleMedium),
          subtitle: Text(
            address.summary,
            style: AppTextStyles.bodyMedium.copyWith(
              color: context.colors.textMuted,
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
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PhoneNumberField(
            controller: controller.phoneController,
            onChanged: controller.onPhoneChanged,
          ),
        ),
        _Input(
          controller: controller.addressLine1Controller,
          label: 'Address line 1',
        ),
        _Input(
          controller: controller.addressLine2Controller,
          label: 'Address line 2',
        ),
        ResponsiveFieldPair(
          // Each _Input already has its own bottom padding.
          stackedSpacing: 0,
          first: _Input(controller: controller.cityController, label: 'City'),
          second: _Input(
            controller: controller.stateController,
            label: 'State',
          ),
        ),
        ResponsiveFieldPair(
          // Each _Input already has its own bottom padding.
          stackedSpacing: 0,
          first: _Input(
            controller: controller.postalCodeController,
            label: 'Postal code',
          ),
          second: _Input(
            controller: controller.countryController,
            label: 'Country',
          ),
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
