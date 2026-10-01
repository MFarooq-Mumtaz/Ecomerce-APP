import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_layout.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/phone_number_field.dart';
import '../controller/become_vendor_controller.dart';

class BecomeVendorView extends GetView<BecomeVendorController> {
  const BecomeVendorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        foregroundColor: context.colors.textPrimary,
        title: Text('Become a Vendor', style: AppTextStyles.titleMedium),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, layout) => ListView(
            padding: layout.pageInsets(
              maxContentWidth: Responsive.formMaxWidth,
            ),
            children: [
              Text(
                'Create your store profile and start managing products.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
              const SizedBox(height: 24),
              _Input(
                controller: controller.storeNameController,
                label: 'Store name',
              ),
              _Input(
                controller: controller.ownerNameController,
                label: 'Owner name',
              ),
              _Input(
                controller: controller.emailController,
                label: 'Contact email',
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PhoneNumberField(
                  controller: controller.phoneController,
                  onChanged: controller.onPhoneChanged,
                ),
              ),
              _Input(
                controller: controller.descriptionController,
                label: 'Store description',
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: AppLayout.buttonHeight,
                child: Obx(
                  () => FilledButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : controller.submit,
                    child: controller.isSubmitting.value
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Store'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        textInputAction: maxLines == 1
            ? TextInputAction.next
            : TextInputAction.newline,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
