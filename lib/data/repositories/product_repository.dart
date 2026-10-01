import '../models/category_model.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

class ProductWriteFailure implements Exception {
  const ProductWriteFailure(this.message);

  final String message;
}

class ProductRepository {
  ProductRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  Future<List<CategoryModel>> getActiveCategories() async {
    final snapshot = await _firestoreService.getActiveCategories();
    final categories =
        snapshot.docs
            .map(CategoryModel.fromFirestore)
            .where((category) => category.name.trim().isNotEmpty)
            .toList()
          ..sort((a, b) {
            final order = a.sortOrder.compareTo(b.sortOrder);
            if (order != 0) {
              return order;
            }
            return a.name.compareTo(b.name);
          });

    return categories;
  }

  Future<List<ProductModel>> getActiveProducts() async {
    final snapshot = await _firestoreService.getActiveProducts();
    return snapshot.docs
        .map(ProductModel.fromFirestore)
        .where((product) => product.name.trim().isNotEmpty)
        .toList();
  }

  /// Active products that have sold at least once, best sellers first.
  ///
  /// Sorting happens in Dart instead of a Firestore orderBy so older seeded
  /// products without a soldCount field are still read safely (as 0).
  Future<List<ProductModel>> getTopSellingProducts({int? limit}) async {
    return topSellingFrom(await getActiveProducts(), limit: limit);
  }

  static List<ProductModel> topSellingFrom(
    Iterable<ProductModel> products, {
    int? limit,
  }) {
    final sorted = products.where((product) => product.soldCount > 0).toList()
      ..sort((a, b) {
        final order = b.soldCount.compareTo(a.soldCount);
        return order != 0 ? order : a.name.compareTo(b.name);
      });
    return limit == null ? sorted : sorted.take(limit).toList();
  }

  Future<List<ProductModel>> getActiveProductsByCategory(
    String categoryId,
  ) async {
    final snapshot = await _firestoreService.getActiveProductsByCategory(
      categoryId,
    );
    return snapshot.docs
        .map(ProductModel.fromFirestore)
        .where((product) => product.name.trim().isNotEmpty)
        .toList();
  }

  Future<ProductModel?> getProductById(String productId) async {
    final snapshot = await _firestoreService.getProductDocument(productId);
    if (!snapshot.exists) {
      return null;
    }

    final product = ProductModel.fromFirestore(snapshot);
    if (!product.isActive || product.name.trim().isEmpty) {
      return null;
    }

    return product;
  }

  Future<List<ProductModel>> getProductsByIds(List<String> productIds) async {
    if (productIds.isEmpty) {
      return <ProductModel>[];
    }

    final products = await Future.wait(productIds.map(getProductById));
    final productById = <String, ProductModel>{};
    for (final product in products) {
      if (product != null) {
        productById[product.id] = product;
      }
    }

    return productIds
        .where(productById.containsKey)
        .map((productId) => productById[productId]!)
        .toList();
  }

  Future<List<ProductModel>> getVendorProducts(String vendorId) async {
    final snapshot = await _firestoreService.getVendorProducts(vendorId);
    final products =
        snapshot.docs
            .map(ProductModel.fromFirestore)
            .where((product) => product.name.trim().isNotEmpty)
            .toList()
          ..sort((a, b) {
            final aDate = a.createdAt;
            final bDate = b.createdAt;
            if (aDate == null || bDate == null) {
              return a.name.compareTo(b.name);
            }
            return bDate.compareTo(aDate);
          });

    return products;
  }

  Future<String> addVendorProduct({
    required String vendorId,
    required ProductModel product,
  }) async {
    try {
      return await _firestoreService.createVendorProduct(
        product.toCreateMap(vendorId: vendorId),
      );
    } catch (_) {
      throw const ProductWriteFailure('Product could not be added.');
    }
  }

  Future<void> updateVendorProduct({
    required String vendorId,
    required ProductModel product,
  }) async {
    try {
      await _firestoreService.updateVendorProduct(
        productId: product.id,
        vendorId: vendorId,
        data: product.toUpdateMap(),
      );
    } catch (_) {
      throw const ProductWriteFailure('Product could not be updated.');
    }
  }

  Future<void> deleteVendorProduct({
    required String vendorId,
    required String productId,
  }) async {
    try {
      await _firestoreService.deleteVendorProduct(
        productId: productId,
        vendorId: vendorId,
      );
    } catch (_) {
      throw const ProductWriteFailure('Product could not be deleted.');
    }
  }
}
