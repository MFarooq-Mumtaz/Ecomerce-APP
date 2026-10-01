import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_layout.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/product_image.dart';
import '../../../../core/widgets/responsive_field_pair.dart';
import '../../../../data/models/category_model.dart';
import '../controller/vendor_product_form_controller.dart';

class VendorProductFormView extends GetView<VendorProductFormController> {
  const VendorProductFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        foregroundColor: context.colors.textPrimary,
        title: Text(
          controller.isEditing ? 'Edit Product' : 'Add Product',
          style: AppTextStyles.titleMedium,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, layout) {
            return ListView(
              padding: layout.pageInsets(
                maxContentWidth: Responsive.formMaxWidth,
              ),
              children: [
                TextField(
                  controller: controller.nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Product name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller.descriptionController,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                ResponsiveFieldPair(
                  first: TextField(
                    controller: controller.priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Price'),
                  ),
                  second: TextField(
                    controller: controller.stockController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Stock'),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => DropdownButtonFormField<CategoryModel>(
                    // initialValue is only read once, so rebuild the field when
                    // categories finish loading or the selection changes.
                    key: ValueKey(
                      '${controller.categories.length}-'
                      '${controller.selectedCategory.value?.id}',
                    ),
                    initialValue: controller.selectedCategory.value,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: controller.isLoadingCategories.value
                          ? 'Loading categories'
                          : 'Category',
                    ),
                    items: controller.categories
                        .map(
                          (category) => DropdownMenuItem<CategoryModel>(
                            value: category,
                            child: Text(category.name),
                          ),
                        )
                        .toList(),
                    onChanged: controller.isLoadingCategories.value
                        ? null
                        : (category) =>
                              controller.selectedCategory.value = category,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => _ProductImagePicker(
                    imageUrl: controller.previewImageUrl,
                    localImagePath: controller.previewLocalImagePath,
                    onPickImage: controller.pickImage,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: controller.isActive.value,
                    onChanged: (value) => controller.isActive.value = value,
                    title: Text(
                      'Active product',
                      style: AppTextStyles.bodyLarge,
                    ),
                    subtitle: Text(
                      'Active products can appear in the customer catalog.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.colors.textMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: AppLayout.buttonHeight,
                  child: Obx(
                    () => FilledButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : controller.save,
                      child: controller.isSaving.value
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              controller.isEditing
                                  ? 'Save Product'
                                  : 'Add Product',
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProductImagePicker extends StatelessWidget {
  const _ProductImagePicker({
    required this.onPickImage,
    this.imageUrl,
    this.localImagePath,
  });

  final String? imageUrl;
  final String? localImagePath;
  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        (imageUrl != null && imageUrl!.isNotEmpty) ||
        (localImagePath != null && localImagePath!.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Product image', style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: ProductImage(
              imageUrl: imageUrl,
              localImagePath: localImagePath,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: AppLayout.buttonHeight,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onPickImage,
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(hasImage ? 'Replace Image' : 'Choose Image'),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Images are stored locally on this device for the current demo.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: context.colors.textMuted,
          ),
        ),
      ],
    );
  }
}
