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
  final searchQuery = ''.obs;
  final errorMessage = RxnString();

  static const topSellingPreviewLimit = 10;

  /// Best sellers by real soldCount, loaded separately from [products].
  final topSellingProducts = <ProductModel>[].obs;

  bool get isSearching => searchQuery.value.trim().isNotEmpty;

  List<HomeProductSection> get categoryProductSections {
    final sections = <HomeProductSection>[];
    final usedProductIds = <String>{};

    for (final category in categories) {
      final categoryProducts = products.where((product) {
        return product.isActive &&
            !usedProductIds.contains(product.id) &&
            _belongsToCategory(product, category);
      }).toList()..sort(_newestFirst);

      if (categoryProducts.isEmpty) {
        continue;
      }

      usedProductIds.addAll(categoryProducts.map((product) => product.id));
      sections.add(
        HomeProductSection(
          title: category.name,
          products: categoryProducts,
          category: category,
        ),
      );
    }

    final uncategorized = <String, List<ProductModel>>{};
    for (final product in products) {
      if (!product.isActive || usedProductIds.contains(product.id)) {
        continue;
      }

      final title = _cleanSectionTitle(product.categoryName);
      uncategorized.putIfAbsent(title, () => <ProductModel>[]).add(product);
    }

    final fallbackTitles = uncategorized.keys.toList()..sort();
    for (final title in fallbackTitles) {
      final sectionProducts = uncategorized[title]!..sort(_newestFirst);
      sections.add(HomeProductSection(title: title, products: sectionProducts));
    }

    return sections;
  }

  /// Search runs over the whole active catalog, not only Top Selling.
  List<ProductModel> get searchResults {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return const <ProductModel>[];
    }

    return products.where((product) {
      return product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query) ||
          (product.categoryName?.toLowerCase().contains(query) ?? false);
    }).toList();
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
      topSellingProducts.assignAll(
        ProductRepository.topSellingFrom(
          products,
          limit: topSellingPreviewLimit,
        ),
      );

      status.value = products.isEmpty && categories.isEmpty
          ? HomeLoadStatus.empty
          : HomeLoadStatus.success;
    } catch (_) {
      errorMessage.value =
          'Home data could not be loaded. Check Firestore access and try again.';
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

  /// Categories "See All" opens the Collections tab with every category.
  void openAllCategories() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (Get.isRegistered<CollectionController>() &&
        Get.isRegistered<AppShellController>()) {
      Get.find<CollectionController>().showCategories();
      Get.find<AppShellController>().selectTab(1);
      return;
    }

    Get.toNamed(AppRoutes.collection);
  }

  /// Top Selling "See All" reuses the same CollectionView.
  void openTopSelling() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (Get.isRegistered<CollectionController>() &&
        Get.isRegistered<AppShellController>()) {
      Get.find<CollectionController>().showTopSelling();
      Get.find<AppShellController>().selectTab(1);
      return;
    }

    Get.toNamed(
      AppRoutes.collection,
      arguments: CollectionController.topSellingArgument,
    );
  }

  void openProductSection(HomeProductSection section) {
    final category = section.category;
    if (category != null) {
      openCategory(category);
    }
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

  bool _belongsToCategory(ProductModel product, CategoryModel category) {
    final categoryId = product.categoryId?.trim();
    if (categoryId != null && categoryId.isNotEmpty) {
      return categoryId == category.id;
    }

    return _normalize(product.categoryName) == _normalize(category.name);
  }

  int _newestFirst(ProductModel a, ProductModel b) {
    final aDate = a.createdAt;
    final bDate = b.createdAt;
    if (aDate != null && bDate != null) {
      final dateOrder = bDate.compareTo(aDate);
      if (dateOrder != 0) {
        return dateOrder;
      }
    }

    return a.name.compareTo(b.name);
  }

  String _cleanSectionTitle(String? value) {
    final title = value?.trim();
    if (title == null || title.isEmpty) {
      return 'More Products';
    }
    return title;
  }

  String _normalize(String? value) => value?.trim().toLowerCase() ?? '';
}

class HomeProductSection {
  const HomeProductSection({
    required this.title,
    required this.products,
    this.category,
  });

  final String title;
  final List<ProductModel> products;
  final CategoryModel? category;
}
