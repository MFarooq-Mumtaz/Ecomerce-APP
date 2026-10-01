import '../models/product_model.dart';
import '../models/wishlist_item_model.dart';
import '../services/firestore_service.dart';
import 'product_repository.dart';

class WishlistRepository {
  WishlistRepository(this._firestoreService, this._productRepository);

  final FirestoreService _firestoreService;
  final ProductRepository _productRepository;

  Future<List<WishlistItemModel>> getWishlistItems(String uid) async {
    final snapshot = await _firestoreService.getWishlistDocuments(uid);
    return snapshot.docs.map(WishlistItemModel.fromFirestore).toList();
  }

  Future<List<ProductModel>> getWishlistProducts(String uid) async {
    final items = await getWishlistItems(uid);
    final productIds = items.map((item) => item.productId).toList();
    return _productRepository.getProductsByIds(productIds);
  }

  Future<void> addProduct({required String uid, required String productId}) {
    return _firestoreService.addWishlistProduct(uid: uid, productId: productId);
  }

  Future<void> removeProduct({required String uid, required String productId}) {
    return _firestoreService.removeWishlistProduct(
      uid: uid,
      productId: productId,
    );
  }
}
