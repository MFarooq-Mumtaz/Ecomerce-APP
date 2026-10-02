import 'package:get/get.dart';

import '../../../data/models/product_model.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../app_shell/controller/app_shell_controller.dart';

enum CartLoadStatus { idle, loading, success, empty, error }

class CartController extends GetxController {
  CartController(this._cartRepository, this._authService);

  final CartRepository _cartRepository;
  final AuthService _authService;

  final status = CartLoadStatus.idle.obs;
  final items = <CartProductItem>[].obs;
  final busyProductIds = <String>{}.obs;
  final errorMessage = RxnString();
  final cartVersion = 0.obs;

  int get itemCount {
    cartVersion.value;
    return items.fold(0, (total, item) => total + item.quantity);
  }

  double get subtotal {
    cartVersion.value;
    return items.fold(0, (total, item) => total + item.lineTotal);
  }

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
      _notifyCartChanged();
      status.value = items.isEmpty
          ? CartLoadStatus.empty
          : CartLoadStatus.success;
    } catch (_) {
      errorMessage.value = 'Cart could not be loaded. Please try again.';
      status.value = CartLoadStatus.error;
    }
  }

  Future<bool> addProduct(
    ProductModel product, {
    bool openCartAfterAdd = false,
  }) async {
    final currentQuantity = quantityFor(product.id);
    final nextQuantity = currentQuantity + 1;
    final didUpdate = await _setProductQuantity(
      product: product,
      quantity: nextQuantity,
      successMessage: currentQuantity == 0
          ? '${product.name} added to cart.'
          : '${product.name} quantity updated.',
    );
    if (didUpdate && openCartAfterAdd) {
      _openCart();
    }
    return didUpdate;
  }

  Future<bool> increaseQuantity(CartProductItem item) {
    return _setProductQuantity(
      product: item.product,
      quantity: item.quantity + 1,
      successMessage: '${item.product.name} quantity updated.',
    );
  }

  Future<bool> decreaseQuantity(CartProductItem item) {
    if (item.quantity <= 1) {
      AppSnackbar.show('Cart', 'Quantity cannot go below 1.');
      return Future<bool>.value(false);
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
    busyProductIds.refresh();
    try {
      await _cartRepository.removeProduct(uid: uid, productId: product.id);
      items.removeWhere((item) => item.product.id == product.id);
      _notifyCartChanged();
      status.value = items.isEmpty
          ? CartLoadStatus.empty
          : CartLoadStatus.success;
      AppSnackbar.show('Cart', '${product.name} removed from cart.');
    } catch (_) {
      AppSnackbar.show('Cart', 'Could not update cart. Try again.');
    } finally {
      busyProductIds.remove(product.id);
      busyProductIds.refresh();
    }
  }

  Future<bool> _setProductQuantity({
    required ProductModel product,
    required int quantity,
    required String successMessage,
  }) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      AppSnackbar.show('Cart', 'Please sign in to use cart.');
      return false;
    }

    if (!_canUseStock(product, quantity)) {
      return false;
    }

    if (busyProductIds.contains(product.id)) {
      return false;
    }

    busyProductIds.add(product.id);
    busyProductIds.refresh();
    try {
      await _cartRepository.setQuantity(
        uid: uid,
        productId: product.id,
        quantity: quantity,
      );
      _upsertLocalItem(product, quantity);
      status.value = CartLoadStatus.success;
      AppSnackbar.show('Cart', successMessage);
      return true;
    } catch (_) {
      AppSnackbar.show('Cart', 'Could not update cart. Try again.');
      return false;
    } finally {
      busyProductIds.remove(product.id);
      busyProductIds.refresh();
    }
  }

  bool _canUseStock(ProductModel product, int nextQuantity) {
    final stock = product.stock;
    if (stock == null) {
      return true;
    }

    if (stock <= 0) {
      AppSnackbar.show('Cart', '${product.name} is out of stock.');
      return false;
    }

    if (nextQuantity > stock) {
      AppSnackbar.show('Cart', 'Only $stock item(s) available.');
      return false;
    }

    return true;
  }

  void _upsertLocalItem(ProductModel product, int quantity) {
    final index = items.indexWhere((item) => item.product.id == product.id);
    final nextItem = CartProductItem(product: product, quantity: quantity);

    if (index == -1) {
      items.insert(0, nextItem);
      _notifyCartChanged();
      return;
    }

    items[index] = nextItem;
    _notifyCartChanged();
  }

  void _notifyCartChanged() {
    items.refresh();
    cartVersion.value += 1;
  }

  void _openCart() {
    if (Get.isRegistered<AppShellController>()) {
      Get.find<AppShellController>().selectTab(2);
      if (Get.currentRoute == AppRoutes.home) {
        return;
      }

      Get.until(
        (route) => route.settings.name == AppRoutes.home || route.isFirst,
      );
      if (Get.currentRoute == AppRoutes.home) {
        return;
      }
    }

    Get.toNamed(AppRoutes.cart);
  }

  void clearSession() {
    items.clear();
    _notifyCartChanged();
    busyProductIds.clear();
    errorMessage.value = null;
    status.value = CartLoadStatus.empty;
  }
}
