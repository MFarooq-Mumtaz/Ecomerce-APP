import 'package:cloud_firestore/cloud_firestore.dart';

import 'address_model.dart';

/// One product line inside an order. The values are copied from the product
/// when the order is placed, so later product edits do not change old orders.
class OrderItemSnapshot {
  const OrderItemSnapshot({
    required this.productId,
    required this.vendorId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.imageUrl,
    this.localImagePath,
    this.categoryId,
    this.categoryName,
  });

  final String productId;
  final String vendorId;
  final String productName;
  final String? imageUrl;
  final String? localImagePath;
  final String? categoryId;
  final String? categoryName;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  factory OrderItemSnapshot.fromMap(Map<String, dynamic> data) {
    final quantity = (data['quantity'] as num?)?.toInt() ?? 0;
    final unitPrice = (data['unitPrice'] as num?)?.toDouble() ?? 0;
    return OrderItemSnapshot(
      productId: data['productId'] as String? ?? '',
      vendorId: data['vendorId'] as String? ?? '',
      productName: data['productName'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      localImagePath: data['localImagePath'] as String?,
      categoryId: data['categoryId'] as String?,
      categoryName: data['categoryName'] as String?,
      quantity: quantity,
      unitPrice: unitPrice,
      lineTotal:
          (data['lineTotal'] as num?)?.toDouble() ?? unitPrice * quantity,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'productId': productId,
      'vendorId': vendorId,
      'productName': productName,
      'imageUrl': imageUrl,
      'localImagePath': localImagePath,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'lineTotal': lineTotal,
    };
  }
}

/// A customer order. One order can contain products from several vendors,
/// so [vendorIds] keeps the unique vendor list for vendor queries.
class OrderModel {
  const OrderModel({
    required this.orderId,
    required this.customerId,
    required this.vendorIds,
    required this.items,
    required this.subtotal,
    required this.total,
    required this.status,
    this.deliveryAddress = const <String, dynamic>{},
    this.createdAt,
  });

  static const pendingStatus = 'pending';

  final String orderId;
  final String customerId;
  final List<String> vendorIds;
  final List<OrderItemSnapshot> items;
  final Map<String, dynamic> deliveryAddress;
  final double subtotal;
  final double total;
  final String status;
  final DateTime? createdAt;

  /// Short reference shown in the UI instead of the full document id.
  String get shortReference {
    final id = orderId.toUpperCase();
    return id.length <= 8 ? id : id.substring(0, 8);
  }

  List<OrderItemSnapshot> itemsForVendor(String vendorId) {
    return items.where((item) => item.vendorId == vendorId).toList();
  }

  factory OrderModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawItems = data['items'] as List<dynamic>? ?? const <dynamic>[];
    final rawVendorIds =
        data['vendorIds'] as List<dynamic>? ?? const <dynamic>[];
    final subtotal = (data['subtotal'] as num?)?.toDouble() ?? 0;

    return OrderModel(
      orderId: data['orderId'] as String? ?? data['id'] as String? ?? doc.id,
      customerId: data['customerId'] as String? ?? '',
      vendorIds: rawVendorIds.whereType<String>().toList(),
      items: rawItems
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (item) => OrderItemSnapshot.fromMap(item.cast<String, dynamic>()),
          )
          .toList(),
      deliveryAddress:
          (data['deliveryAddress'] as Map<dynamic, dynamic>?)
              ?.cast<String, dynamic>() ??
          const <String, dynamic>{},
      subtotal: subtotal,
      total: (data['total'] as num?)?.toDouble() ?? subtotal,
      status: data['status'] as String? ?? pendingStatus,
      createdAt: _readTimestamp(data['createdAt']),
    );
  }

  static DateTime? _readTimestamp(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}

class PlaceOrderResult {
  const PlaceOrderResult({required this.orderId});

  final String orderId;
}

class PlaceOrderDraft {
  const PlaceOrderDraft({required this.customerId, required this.address});

  final String customerId;
  final AddressModel address;
}
