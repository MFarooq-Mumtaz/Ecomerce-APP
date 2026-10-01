import 'package:get/get.dart';

import '../../../data/models/product_model.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../data/services/auth_service.dart';

enum CartLoadStatus { idle, loading, success, empty, error }

class CartController extends GetxController {
  CartController(this._cartRepository, this._authService);

  final CartRepository _cartRepository;
  final AuthService _authService;

  final status = CartLoadStatus.idle.obs;
  final items = <CartProductItem>[].obs;
  final busyProductIds = <String>{}.obs;
  final errorMessage = RxnString();

  int get itemCount => items.fold(0, (total, item) => total + item.quantity);

  double get subtotal => items.fold(0, (total, item) => total + item.lineTotal);

  bool isInCart(String productId) =>
      items.any((item) => item.product.id == productId);

  int quantityFor(String productId) {
    for (final item in items) {
      if (item.product.id == productId) {
        return item.quantity;
      }
    }
    return 0;
  }

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  Future<void> loadCart() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      clearSession();
      return;
    }

    if (items.isEmpty) {
      status.value = CartLoadStatus.loading;
    }
    errorMessage.value = null;

    try {
      final loadedItems = await _cartRepository.getCartProductItems(uid);
      items.assignAll(loadedItems);
      status.value = items.isEmpty
          ? CartLoadStatus.empty
          : CartLoadStatus.success;
    } catch (_) {
      errorMessage.value = 'Cart could not be loaded. Please try again.';
      status.value = CartLoadStatus.error;
    }
  }

  Future<void> addProduct(ProductModel product) async {
    final currentQuantity = quantityFor(product.id);
    final nextQuantity = currentQuantity + 1;
    await _setProductQuantity(
      product: product,
      quantity: nextQuantity,
      successMessage: currentQuantity == 0
          ? '${product.name} added to cart.'
          : '${product.name} quantity updated.',
    );
  }

  Future<void> increaseQuantity(CartProductItem item) {
    return _setProductQuantity(
      product: item.product,
      quantity: item.quantity + 1,
      successMessage: '${item.product.name} quantity updated.',
    );
  }

  Future<void> decreaseQuantity(CartProductItem item) {
    if (item.quantity <= 1) {
      Get.snackbar('Cart', 'Quantity cannot go below 1.');
      return Future<void>.value();
    }

    return _setProductQuantity(
      product: item.product,
      quantity: item.quantity - 1,
      successMessage: '${item.product.name} quantity updated.',
    );
  }

  Future<void> removeProduct(ProductModel product) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      clearSession();
      return;
    }

    if (busyProductIds.contains(product.id)) {
      return;
    }

    busyProductIds.add(product.id);
    try {
      await _cartRepository.removeProduct(uid: uid, productId: product.id);
      items.removeWhere((item) => item.product.id == product.id);
      status.value = items.isEmpty
          ? CartLoadStatus.empty
          : CartLoadStatus.success;
      Get.snackbar('Cart', '${product.name} removed from cart.');
    } catch (_) {
      Get.snackbar('Cart', 'Could not update cart. Try again.');
    } finally {
      busyProductIds.remove(product.id);
    }
  }

  Future<void> _setProductQuantity({
    required ProductModel product,
    required int quantity,
    required String successMessage,
  }) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      Get.snackbar('Cart', 'Please sign in to use cart.');
      return;
    }

    if (!_canUseStock(product, quantity)) {
      return;
    }

    if (busyProductIds.contains(product.id)) {
      return;
    }

    busyProductIds.add(product.id);
    try {
      await _cartRepository.setQuantity(
        uid: uid,
        productId: product.id,
        quantity: quantity,
      );
      _upsertLocalItem(product, quantity);
      status.value = CartLoadStatus.success;
      Get.snackbar('Cart', successMessage);
    } catch (_) {
      Get.snackbar('Cart', 'Could not update cart. Try again.');
    } finally {
      busyProductIds.remove(product.id);
    }
  }

  bool _canUseStock(ProductModel product, int nextQuantity) {
    final stock = product.stock;
    if (stock == null) {
      return true;
    }

    if (stock <= 0) {
      Get.snackbar('Cart', '${product.name} is out of stock.');
      return false;
    }

    if (nextQuantity > stock) {
      Get.snackbar('Cart', 'Only $stock item(s) available.');
      return false;
    }

    return true;
  }

  void _upsertLocalItem(ProductModel product, int quantity) {
    final index = items.indexWhere((item) => item.product.id == product.id);
    final nextItem = CartProductItem(product: product, quantity: quantity);

    if (index == -1) {
      items.insert(0, nextItem);
      return;
    }

    items[index] = nextItem;
  }

  void clearSession() {
    items.clear();
    busyProductIds.clear();
    errorMessage.value = null;
    status.value = CartLoadStatus.empty;
  }
}
