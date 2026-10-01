import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get categories =>
      _firestore.collection('categories');

  CollectionReference<Map<String, dynamic>> get products =>
      _firestore.collection('products');

  CollectionReference<Map<String, dynamic>> wishlist(String uid) =>
      users.doc(uid).collection('wishlist');

  CollectionReference<Map<String, dynamic>> cart(String uid) =>
      users.doc(uid).collection('cart');

  CollectionReference<Map<String, dynamic>> addresses(String uid) =>
      users.doc(uid).collection('addresses');

  CollectionReference<Map<String, dynamic>> get orders =>
      _firestore.collection('orders');

  CollectionReference<Map<String, dynamic>> get vendors =>
      _firestore.collection('vendors');

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDocument(String uid) {
    return users.doc(uid).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getActiveCategories() {
    return categories.where('isActive', isEqualTo: true).limit(24).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getActiveProducts() {
    return products.where('isActive', isEqualTo: true).limit(50).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getActiveProductsByCategory(
    String categoryId,
  ) {
    return products
        .where('isActive', isEqualTo: true)
        .where('categoryId', isEqualTo: categoryId)
        .limit(50)
        .get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getProductDocument(
    String productId,
  ) {
    return products.doc(productId).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getVendorProducts(
    String vendorId,
  ) {
    return products.where('vendorId', isEqualTo: vendorId).limit(100).get();
  }

  Future<String> createVendorProduct(Map<String, Object?> data) async {
    final productDocument = products.doc();
    await productDocument.set(data);
    return productDocument.id;
  }

  Future<void> updateVendorProduct({
    required String productId,
    required String vendorId,
    required Map<String, Object?> data,
  }) {
    final productDocument = products.doc(productId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(productDocument);
      if (!snapshot.exists) {
        throw StateError('Product does not exist.');
      }

      final existingVendorId = snapshot.data()?['vendorId'] as String?;
      if (existingVendorId != vendorId) {
        throw StateError('You can update only your own products.');
      }

      transaction.update(productDocument, data);
    });
  }

  Future<void> deleteVendorProduct({
    required String productId,
    required String vendorId,
  }) {
    final productDocument = products.doc(productId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(productDocument);
      if (!snapshot.exists) {
        throw StateError('Product does not exist.');
      }

      final existingVendorId = snapshot.data()?['vendorId'] as String?;
      if (existingVendorId != vendorId) {
        throw StateError('You can delete only your own products.');
      }

      transaction.delete(productDocument);
    });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getWishlistDocuments(String uid) {
    return wishlist(uid).orderBy('createdAt', descending: true).get();
  }

  Future<void> addWishlistProduct({
    required String uid,
    required String productId,
  }) {
    return wishlist(uid).doc(productId).set(<String, Object>{
      'productId': productId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeWishlistProduct({
    required String uid,
    required String productId,
  }) {
    return wishlist(uid).doc(productId).delete();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getCartDocuments(String uid) {
    return cart(uid).orderBy('updatedAt', descending: true).get();
  }

  Future<void> setCartProductQuantity({
    required String uid,
    required String productId,
    required int quantity,
  }) {
    final cartDocument = cart(uid).doc(productId);
    final safeQuantity = quantity < 1 ? 1 : quantity;

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(cartDocument);
      if (snapshot.exists) {
        transaction.update(cartDocument, <Object, Object>{
          'quantity': safeQuantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return;
      }

      transaction.set(cartDocument, <String, Object>{
        'productId': productId,
        'quantity': safeQuantity,
        'addedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> removeCartProduct({
    required String uid,
    required String productId,
  }) {
    return cart(uid).doc(productId).delete();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAddressDocuments(String uid) {
    return addresses(uid).orderBy('createdAt', descending: false).get();
  }

  Future<String> createAddress({
    required String uid,
    required Map<String, Object?> data,
    required bool makeDefault,
  }) async {
    final addressCollection = addresses(uid);
    final newAddress = addressCollection.doc();

    await _firestore.runTransaction((transaction) async {
      if (makeDefault) {
        final existing = await addressCollection.get();
        for (final doc in existing.docs) {
          transaction.update(doc.reference, <Object, Object?>{
            'isDefault': false,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      transaction.set(newAddress, data);
    });

    return newAddress.id;
  }

  Future<String> createOrderFromCart({
    required String uid,
    required List<String> productIds,
    required Map<String, Object?> Function(String orderId) orderDataBuilder,
    required Map<String, Object?> Function(
      String productId,
      Map<String, dynamic> productData,
      int quantity,
    )
    itemDataBuilder,
  }) async {
    final orderDocument = orders.doc();
    final cartDocuments = productIds.map((id) => cart(uid).doc(id)).toList();
    final productDocuments = productIds.map((id) => products.doc(id)).toList();

    await _firestore.runTransaction((transaction) async {
      final cartSnapshots = <DocumentSnapshot<Map<String, dynamic>>>[];
      for (final cartDocument in cartDocuments) {
        cartSnapshots.add(await transaction.get(cartDocument));
      }

      final productSnapshots = <DocumentSnapshot<Map<String, dynamic>>>[];
      for (final productDocument in productDocuments) {
        productSnapshots.add(await transaction.get(productDocument));
      }

      final orderItems = <Map<String, Object?>>[];
      for (var index = 0; index < productIds.length; index += 1) {
        final cartSnapshot = cartSnapshots[index];
        final productSnapshot = productSnapshots[index];
        final productId = productIds[index];

        if (!cartSnapshot.exists) {
          throw StateError('Cart item is no longer available.');
        }
        if (!productSnapshot.exists) {
          throw StateError('A product is no longer available.');
        }

        final cartData = cartSnapshot.data() ?? <String, dynamic>{};
        final productData = productSnapshot.data() ?? <String, dynamic>{};
        final quantity = (cartData['quantity'] as num?)?.toInt() ?? 0;
        final stock = (productData['stock'] as num?)?.toInt();
        final isActive = productData['isActive'] as bool? ?? false;
        final vendorId = productData['vendorId'] as String? ?? '';

        if (quantity < 1) {
          throw StateError('Cart quantity is invalid.');
        }
        if (!isActive) {
          throw StateError('A product is no longer active.');
        }
        if (vendorId.trim().isEmpty) {
          throw StateError('A product is missing vendor information.');
        }
        if (stock != null) {
          if (stock < quantity) {
            throw StateError('A product does not have enough stock.');
          }
        }

        final itemData = itemDataBuilder(productId, productData, quantity);
        orderItems.add(itemData);
      }

      final orderData = orderDataBuilder(orderDocument.id);
      transaction.set(orderDocument, <String, Object?>{
        ...orderData,
        'items': orderItems,
      });

      for (final cartDocument in cartDocuments) {
        transaction.delete(cartDocument);
      }
    });

    return orderDocument.id;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getVendorDocument(String uid) {
    return vendors.doc(uid).get();
  }

  Future<void> convertCustomerToVendor({
    required String uid,
    required Map<String, Object?> vendorData,
  }) {
    final userDocument = users.doc(uid);
    final vendorDocument = vendors.doc(uid);

    return _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userDocument);
      if (!userSnapshot.exists) {
        throw StateError('User profile does not exist.');
      }

      final userData = userSnapshot.data() ?? <String, dynamic>{};
      final currentRole = userData['role'] as String? ?? 'customer';
      final currentVendorId = userData['vendorId'] as String?;

      final vendorSnapshot = await transaction.get(vendorDocument);
      if (vendorSnapshot.exists) {
        transaction.update(userDocument, <Object, Object?>{
          'role': 'vendor',
          'vendorId': uid,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return;
      }

      if (currentRole != 'customer' && currentVendorId != uid) {
        throw StateError('Only customer accounts can become vendors.');
      }

      transaction.set(vendorDocument, vendorData);
      transaction.update(userDocument, <Object, Object?>{
        'role': 'vendor',
        'vendorId': uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<bool> createUserDocumentIfMissing({
    required String uid,
    required Map<String, dynamic> data,
  }) {
    final userDocument = users.doc(uid);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userDocument);
      if (snapshot.exists) {
        return false;
      }

      transaction.set(userDocument, data);
      return true;
    });
  }

  Future<void> updateUserProfile({
    required String uid,
    required String displayName,
    required String? photoUrl,
  }) {
    return users.doc(uid).update(<Object, Object?>{
      'displayName': displayName.trim(),
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
