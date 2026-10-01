import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../data/models/category_model.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../data/services/local_product_image_service.dart';
import '../../../../core/widgets/app_snackbar.dart';

class VendorProductFormController extends GetxController {
  VendorProductFormController(
    this._authService,
    this._productRepository,
    this._imageService,
  );

  final AuthService _authService;
  final ProductRepository _productRepository;
  final LocalProductImageService _imageService;
  final _imagePicker = ImagePicker();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();

  final categories = <CategoryModel>[].obs;
  final selectedCategory = Rxn<CategoryModel>();
  final pickedImagePath = RxnString();
  final isActive = true.obs;
  final isSaving = false.obs;
  final isLoadingCategories = false.obs;
  ProductModel? editingProduct;

  bool get isEditing => editingProduct != null;
  String? get previewLocalImagePath =>
      pickedImagePath.value ?? editingProduct?.localImagePath;
  String? get previewImageUrl =>
      pickedImagePath.value == null ? editingProduct?.imageUrl : null;

  @override
  void onInit() {
    super.onInit();
    final argument = Get.arguments;
    if (argument is ProductModel) {
      editingProduct = argument;
      _fillFromProduct(argument);
    }
    loadCategories();
  }

  Future<void> loadCategories() async {
    isLoadingCategories.value = true;
    try {
      final loadedCategories = await _productRepository.getActiveCategories();
      categories.assignAll(loadedCategories);
      final product = editingProduct;
      if (product != null && product.categoryId != null) {
        for (final category in loadedCategories) {
          if (category.id == product.categoryId) {
            selectedCategory.value = category;
            break;
          }
        }
      }
    } catch (_) {
      AppSnackbar.show('Product', 'Categories could not be loaded. Try again.');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 86,
      );
      if (image == null) {
        return;
      }
      pickedImagePath.value = image.path;
    } catch (_) {
      AppSnackbar.show('Product image', 'Could not open image picker.');
    }
  }

  Future<void> save() async {
    final vendorId = _authService.currentUser?.uid;
    if (vendorId == null || isSaving.value) {
      return;
    }

    final validation = _validate();
    if (validation != null) {
      AppSnackbar.show('Product', validation);
      return;
    }

    isSaving.value = true;
    String? savedLocalImagePath;
    try {
      final category = selectedCategory.value;
      final replacementImagePath = pickedImagePath.value;
      if (replacementImagePath != null && replacementImagePath.isNotEmpty) {
        savedLocalImagePath = await _imageService.saveProductImage(
          replacementImagePath,
        );
      }

      final product = ProductModel(
        id: editingProduct?.id ?? '',
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        price: double.parse(priceController.text.trim()),
        imageUrl: savedLocalImagePath == null ? editingProduct?.imageUrl : null,
        localImagePath: savedLocalImagePath ?? editingProduct?.localImagePath,
        categoryId: category?.id,
        categoryName: category?.name,
        vendorId: vendorId,
        stock: int.parse(stockController.text.trim()),
        isActive: isActive.value,
      );

      if (isEditing) {
        await _productRepository.updateVendorProduct(
          vendorId: vendorId,
          product: product,
        );
        if (savedLocalImagePath != null) {
          await _imageService.deleteIfOwnedProductImage(
            editingProduct?.localImagePath,
          );
        }
        Get.closeAllSnackbars();
        Get.back();
        AppSnackbar.show('Product', 'Product updated.');
        return;
      }

      await _productRepository.addVendorProduct(
        vendorId: vendorId,
        product: product,
      );
      Get.closeAllSnackbars();
      Get.back();
      AppSnackbar.show('Product', 'Product added.');
    } on ProductWriteFailure catch (failure) {
      await _imageService.deleteIfOwnedProductImage(savedLocalImagePath);
      AppSnackbar.show('Product', failure.message);
    } catch (_) {
      await _imageService.deleteIfOwnedProductImage(savedLocalImagePath);
      AppSnackbar.show('Product', 'Product could not be saved.');
    } finally {
      isSaving.value = false;
    }
  }

  String? _validate() {
    if (nameController.text.trim().isEmpty) {
      return 'Enter product name.';
    }
    if (descriptionController.text.trim().isEmpty) {
      return 'Enter product description.';
    }

    final price = double.tryParse(priceController.text.trim());
    if (price == null || price <= 0) {
      return 'Enter a valid price.';
    }

    final stock = int.tryParse(stockController.text.trim());
    if (stock == null || stock < 0) {
      return 'Enter a valid stock quantity.';
    }

    if (selectedCategory.value == null) {
      return 'Select a category.';
    }

    return null;
  }

  void _fillFromProduct(ProductModel product) {
    nameController.text = product.name;
    descriptionController.text = product.description;
    priceController.text = product.price.toStringAsFixed(2);
    stockController.text = (product.stock ?? 0).toString();
    isActive.value = product.isActive;
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.onClose();
  }
}
