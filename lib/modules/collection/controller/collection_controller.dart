import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';

enum CollectionLoadStatus { idle, loading, success, empty, error }

class CollectionController extends GetxController {
  CollectionController(this._productRepository);

  final ProductRepository _productRepository;

  final status = CollectionLoadStatus.idle.obs;
  final categories = <CategoryModel>[].obs;
  final products = <ProductModel>[].obs;
  final selectedCategory = Rxn<CategoryModel>();
  final errorMessage = RxnString();
  CategoryModel? get category => selectedCategory.value;

  @override
  void onInit() {
    super.onInit();
    final argument = Get.arguments;
    if (argument is CategoryModel) {
      selectedCategory.value = argument;
      loadProducts();
      return;
    }

    loadCategories();
  }

  Future<void> loadCategories() async {
    status.value = CollectionLoadStatus.loading;
    errorMessage.value = null;

    try {
      final loadedCategories = await _productRepository.getActiveCategories();
      categories.assignAll(loadedCategories);
      status.value = loadedCategories.isEmpty
          ? CollectionLoadStatus.empty
          : CollectionLoadStatus.success;
    } catch (_) {
      errorMessage.value = 'Collections could not be loaded.';
      status.value = CollectionLoadStatus.error;
    }
  }

  Future<void> loadProducts() async {
    final currentCategory = selectedCategory.value;
    if (currentCategory == null) {
      await loadCategories();
      return;
    }

    status.value = CollectionLoadStatus.loading;
    errorMessage.value = null;

    try {
      final loadedProducts = await _productRepository
          .getActiveProductsByCategory(currentCategory.id);
      products.assignAll(loadedProducts);
      status.value = products.isEmpty
          ? CollectionLoadStatus.empty
          : CollectionLoadStatus.success;
    } catch (_) {
      errorMessage.value = 'Collection products could not be loaded.';
      status.value = CollectionLoadStatus.error;
    }
  }

  void selectCategory(CategoryModel category) {
    selectedCategory.value = category;
    loadProducts();
  }

  void showCategories() {
    selectedCategory.value = null;
    products.clear();
    loadCategories();
  }

  void openProduct(ProductModel product) {
    FocusManager.instance.primaryFocus?.unfocus();
    Get.toNamed(AppRoutes.productDetail, arguments: product);
  }
}
