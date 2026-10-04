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

  Future<PlaceOrderResult> createOrder({
    required PlaceOrderDraft draft,
    required List<CartProductItem> cartItems,
  }) async {
    if (cartItems.isEmpty) {
      throw const OrderFailure('Your cart is empty.');
    }

    try {
      final orderId = await _firestoreService.createOrderFromCart(
        uid: draft.customerId,
        productIds: cartItems.map((item) => item.product.id).toList(),
        orderDataBuilder: (orderId, lines) {
          // Prices and vendor ids come from the product documents read inside
          // the transaction, not from the cached cart on the device.
          final items = lines.map(_buildItem).toList();
          final vendorIds = items.map((item) => item.vendorId).toSet().toList();
          final subtotal = items.fold<double>(
            0,
            (total, item) => total + item.lineTotal,
          );
          final itemCount = items.fold<int>(
            0,
            (total, item) => total + item.quantity,
          );

          return <String, Object?>{
            'orderId': orderId,
            'customerId': draft.customerId,
            'vendorIds': vendorIds,
            'items': items.map((item) => item.toMap()).toList(),
            'itemCount': itemCount,
            'deliveryAddress': draft.address.toOrderSnapshot(),
            'subtotal': subtotal,
            'total': subtotal,
            'status': OrderModel.pendingStatus,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          };
        },
      );

      return PlaceOrderResult(orderId: orderId);
    } on StateError catch (error) {
      throw OrderFailure(error.message);
    } catch (_) {
      throw const OrderFailure('Order could not be placed. Please try again.');
    }
  }

  /// Orders that contain at least one product from [vendorId], newest first.
  Future<List<OrderModel>> getVendorOrders(String vendorId) async {
    final snapshot = await _firestoreService.getVendorOrders(vendorId);
    final orders = snapshot.docs.map(OrderModel.fromFirestore).toList()
      ..sort((a, b) {
        final aDate = a.createdAt;
        final bDate = b.createdAt;
        if (aDate == null || bDate == null) {
          return 0;
        }
        return bDate.compareTo(aDate);
      });
    return orders;
  }

  OrderItemSnapshot _buildItem(CartOrderLine line) {
    final data = line.productData;
    final unitPrice = (data['price'] as num?)?.toDouble() ?? 0;
    return OrderItemSnapshot(
      productId: line.productId,
      vendorId: data['vendorId'] as String? ?? '',
      productName: data['name'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      localImagePath: data['localImagePath'] as String?,
      categoryId: data['categoryId'] as String?,
      categoryName: data['categoryName'] as String?,
      quantity: line.quantity,
      unitPrice: unitPrice,
      lineTotal: unitPrice * line.quantity,
    );
  }
}
