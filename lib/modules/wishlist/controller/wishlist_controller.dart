import 'package:get/get.dart';

import '../../../data/models/product_model.dart';
import '../../../data/repositories/wishlist_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../../core/widgets/app_snackbar.dart';

enum WishlistLoadStatus { idle, loading, success, empty, error }

class WishlistController extends GetxController {
  WishlistController(this._wishlistRepository, this._authService);

  final WishlistRepository _wishlistRepository;
  final AuthService _authService;

  final status = WishlistLoadStatus.idle.obs;
  final productIds = <String>{}.obs;
  final products = <ProductModel>[].obs;
  final busyProductIds = <String>{}.obs;
  final errorMessage = RxnString();

  bool isWishlisted(String productId) => productIds.contains(productId);

  @override
  void onInit() {
    super.onInit();
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      clearSession();
      return;
    }

    if (products.isEmpty && productIds.isEmpty) {
      status.value = WishlistLoadStatus.loading;
    }
    errorMessage.value = null;

    try {
      final items = await _wishlistRepository.getWishlistItems(uid);
      final loadedProducts = await _wishlistRepository.getWishlistProducts(uid);

      productIds.assignAll(items.map((item) => item.productId));
      products.assignAll(loadedProducts);
      status.value = productIds.isEmpty
          ? WishlistLoadStatus.empty
          : WishlistLoadStatus.success;
    } catch (_) {
      errorMessage.value = 'Wishlist could not be loaded. Please try again.';
      status.value = WishlistLoadStatus.error;
    }
  }

  Future<void> toggleProduct(ProductModel product) async {
    if (busyProductIds.contains(product.id)) {
      return;
    }

    if (isWishlisted(product.id)) {
      await removeProduct(product);
      return;
    }

    await addProduct(product);
  }

  Future<void> addProduct(ProductModel product) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      AppSnackbar.show('Wishlist', 'Please sign in to use wishlist.');
      return;
    }

    if (busyProductIds.contains(product.id)) {
      return;
    }

    busyProductIds.add(product.id);
    try {
      await _wishlistRepository.addProduct(uid: uid, productId: product.id);
      productIds.add(product.id);
      if (!products.any((item) => item.id == product.id)) {
        products.insert(0, product);
      }
      status.value = WishlistLoadStatus.success;
      AppSnackbar.show('Wishlist', '${product.name} added to wishlist.');
    } catch (_) {
      AppSnackbar.show('Wishlist', 'Could not update wishlist. Try again.');
    } finally {
      busyProductIds.remove(product.id);
    }
  }

  Future<void> removeProduct(ProductModel product) async {
    await removeProductById(product.id, productName: product.name);
  }

  Future<void> removeProductById(
    String productId, {
    String? productName,
  }) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      clearSession();
      return;
    }

    if (busyProductIds.contains(productId)) {
      return;
    }

    busyProductIds.add(productId);
    try {
      await _wishlistRepository.removeProduct(uid: uid, productId: productId);
      productIds.remove(productId);
      products.removeWhere((product) => product.id == productId);
      status.value = productIds.isEmpty
          ? WishlistLoadStatus.empty
          : WishlistLoadStatus.success;
      AppSnackbar.show(
        'Wishlist',
        productName == null
            ? 'Product removed from wishlist.'
            : '$productName removed from wishlist.',
      );
    } catch (_) {
      AppSnackbar.show('Wishlist', 'Could not update wishlist. Try again.');
    } finally {
      busyProductIds.remove(productId);
    }
  }

  void clearSession() {
    productIds.clear();
    products.clear();
    busyProductIds.clear();
    errorMessage.value = null;
    status.value = WishlistLoadStatus.empty;
  }
}
