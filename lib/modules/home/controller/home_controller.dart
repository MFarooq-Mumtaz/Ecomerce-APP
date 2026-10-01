import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../app_shell/controller/app_shell_controller.dart';
import '../../collection/controller/collection_controller.dart';

enum HomeLoadStatus { idle, loading, success, empty, error }

class HomeController extends GetxController {
  HomeController(this._productRepository);

  final ProductRepository _productRepository;

  final searchController = TextEditingController();
  final status = HomeLoadStatus.idle.obs;
  final categories = <CategoryModel>[].obs;
  final products = <ProductModel>[].obs;
  final selectedCategoryId = RxnString();
  final searchQuery = ''.obs;
  final errorMessage = RxnString();

  List<ProductModel> get filteredProducts {
    final query = searchQuery.value.trim().toLowerCase();
    final categoryId = selectedCategoryId.value;

    return products.where((product) {
      final matchesCategory =
          categoryId == null || product.categoryId == categoryId;
      final matchesSearch =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query) ||
          (product.categoryName?.toLowerCase().contains(query) ?? false);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<ProductModel> get topSellingProducts {
    final filtered = filteredProducts;
    return filtered.take(5).toList();
  }

  List<ProductModel> get newProducts {
    final filtered = filteredProducts;
    if (filtered.length <= 5) {
      return filtered;
    }
    return filtered.skip(5).take(5).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadHome();
  }

  Future<void> loadHome() async {
    if (products.isEmpty && categories.isEmpty) {
      status.value = HomeLoadStatus.loading;
    }
    errorMessage.value = null;

    try {
      final results = await Future.wait([
        _productRepository.getActiveCategories(),
        _productRepository.getActiveProducts(),
      ]);

      categories.assignAll(results[0] as List<CategoryModel>);
      products.assignAll(results[1] as List<ProductModel>);

      if (selectedCategoryId.value != null &&
          !categories.any(
            (category) => category.id == selectedCategoryId.value,
          )) {
        selectedCategoryId.value = null;
      }

      status.value = products.isEmpty && categories.isEmpty
          ? HomeLoadStatus.empty
          : HomeLoadStatus.success;
    } catch (_) {
      errorMessage.value = 'Home data could not be loaded. Check Firestore access and try again.';
      status.value = HomeLoadStatus.error;
    }
  }

  Future<void> refreshHome() => loadHome();

  void updateSearch(String value) {
    searchQuery.value = value;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  void openCategory(CategoryModel category) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (Get.isRegistered<CollectionController>() &&
        Get.isRegistered<AppShellController>()) {
      Get.find<CollectionController>().selectCategory(category);
      Get.find<AppShellController>().selectTab(1);
      return;
    }

    Get.toNamed(AppRoutes.collection, arguments: category);
  }

  void openProduct(ProductModel product) {
    FocusManager.instance.primaryFocus?.unfocus();
    Get.toNamed(AppRoutes.productDetail, arguments: product);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
