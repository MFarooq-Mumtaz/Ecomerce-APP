import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';
import 'product_repository.dart';

class CartProductItem {
  const CartProductItem({required this.product, required this.quantity});

  final ProductModel product;
  final int quantity;

  double get lineTotal => product.price * quantity;
}

class CartRepository {
  CartRepository(this._firestoreService, this._productRepository);

  final FirestoreService _firestoreService;
  final ProductRepository _productRepository;

  Future<List<CartItemModel>> getCartItems(String uid) async {
    final snapshot = await _firestoreService.getCartDocuments(uid);
    return snapshot.docs.map(CartItemModel.fromFirestore).toList();
  }

  Future<List<CartProductItem>> getCartProductItems(String uid) async {
    final items = await getCartItems(uid);
    final products = await _productRepository.getProductsByIds(
      items.map((item) => item.productId).toList(),
    );
    final productById = {for (final product in products) product.id: product};

    return items
        .where((item) => productById.containsKey(item.productId))
        .map(
          (item) => CartProductItem(
            product: productById[item.productId]!,
            quantity: item.quantity,
          ),
        )
        .toList();
  }

  Future<void> setQuantity({
    required String uid,
    required String productId,
    required int quantity,
  }) {
    return _firestoreService.setCartProductQuantity(
      uid: uid,
      productId: productId,
      quantity: quantity,
    );
  }

  Future<void> removeProduct({required String uid, required String productId}) {
    return _firestoreService.removeCartProduct(uid: uid, productId: productId);
  }
}
