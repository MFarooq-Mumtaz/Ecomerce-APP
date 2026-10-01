import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../data/services/local_product_image_service.dart';

enum VendorProductsStatus { idle, loading, success, empty, error }

class VendorProductsController extends GetxController {
  VendorProductsController(
    this._authService,
    this._productRepository,
    this._imageService,
  );

  final AuthService _authService;
  final ProductRepository _productRepository;
  final LocalProductImageService _imageService;

  final status = VendorProductsStatus.idle.obs;
  final products = <ProductModel>[].obs;
  final errorMessage = RxnString();
  final deletingProductIds = <String>{}.obs;

  String? get vendorId => _authService.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final id = vendorId;
    if (id == null) {
      status.value = VendorProductsStatus.error;
      errorMessage.value = 'Please sign in to manage products.';
      return;
    }

    status.value = VendorProductsStatus.loading;
    errorMessage.value = null;

    try {
      final loadedProducts = await _productRepository.getVendorProducts(id);
      products.assignAll(loadedProducts);
      status.value = loadedProducts.isEmpty
          ? VendorProductsStatus.empty
          : VendorProductsStatus.success;
    } catch (_) {
      errorMessage.value = 'Products could not be loaded.';
      status.value = VendorProductsStatus.error;
    }
  }

  void addProduct() {
    Get.toNamed(AppRoutes.vendorProductForm)?.then((_) => loadProducts());
  }

  void editProduct(ProductModel product) {
    Get.toNamed(
      AppRoutes.vendorProductForm,
      arguments: product,
    )?.then((_) => loadProducts());
  }

  Future<void> confirmDelete(ProductModel product) async {
    final shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete product?'),
        content: Text('Remove ${product.name} from your store?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await deleteProduct(product);
    }
  }

  Future<void> deleteProduct(ProductModel product) async {
    final id = vendorId;
    if (id == null || deletingProductIds.contains(product.id)) {
      return;
    }

    deletingProductIds.add(product.id);
    try {
      await _productRepository.deleteVendorProduct(
        vendorId: id,
        productId: product.id,
      );
      await _imageService.deleteIfOwnedProductImage(product.localImagePath);
      products.removeWhere((item) => item.id == product.id);
      if (products.isEmpty) {
        status.value = VendorProductsStatus.empty;
      }
      AppSnackbar.show('Products', 'Product deleted.');
    } on ProductWriteFailure catch (failure) {
      AppSnackbar.show('Products', failure.message);
    } finally {
      deletingProductIds.remove(product.id);
    }
  }
}
