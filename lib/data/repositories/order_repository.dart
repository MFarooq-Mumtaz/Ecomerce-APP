import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_models.dart';
import '../services/firestore_service.dart';
import 'cart_repository.dart';

class OrderFailure implements Exception {
  const OrderFailure(this.message);

  final String message;
}

class OrderRepository {
  OrderRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  Future<PlaceOrderResult> placeOrder({
    required PlaceOrderDraft draft,
    required List<CartProductItem> cartItems,
  }) async {
    if (cartItems.isEmpty) {
      throw const OrderFailure('Your cart is empty.');
    }

    try {
      final productIds = cartItems.map((item) => item.product.id).toList();
      final quantityByProductId = {
        for (final item in cartItems) item.product.id: item.quantity,
      };
      final subtotal = cartItems.fold<double>(
        0,
        (total, item) => total + item.lineTotal,
      );
      final itemCount = cartItems.fold<int>(
        0,
        (total, item) => total + item.quantity,
      );
      final total = subtotal + draft.shipping;

      final orderId = await _firestoreService.createOrderFromCart(
        uid: draft.customerId,
        productIds: productIds,
        orderDataBuilder: (orderId) => <String, Object?>{
          'id': orderId,
          'customerId': draft.customerId,
          'customerEmail': draft.customerEmail,
          'customerName': draft.customerName,
          'status': 'pending',
          'subtotal': subtotal,
          'shipping': draft.shipping,
          'total': total,
          'itemCount': itemCount,
          'deliveryAddress': draft.address.toOrderSnapshot(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        itemDataBuilder: (productId, productData, quantity) {
          final unitPrice = (productData['price'] as num?)?.toDouble() ?? 0;
          return OrderItemSnapshot(
            productId: productId,
            vendorId: productData['vendorId'] as String? ?? '',
            productName: productData['name'] as String? ?? '',
            imageUrl: productData['imageUrl'] as String?,
            quantity: quantityByProductId[productId] ?? quantity,
            unitPrice: unitPrice,
            lineTotal: unitPrice * (quantityByProductId[productId] ?? quantity),
          ).toMap();
        },
      );

      return PlaceOrderResult(orderId: orderId);
    } on OrderFailure {
      rethrow;
    } on StateError catch (error) {
      throw OrderFailure(error.message);
    } catch (_) {
      throw const OrderFailure('Order could not be placed. Please try again.');
    }
  }
}
