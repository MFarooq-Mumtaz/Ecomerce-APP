import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemModel {
  const CartItemModel({
    required this.productId,
    required this.quantity,
    this.addedAt,
    this.updatedAt,
  });

  final String productId;
  final int quantity;
  final DateTime? addedAt;
  final DateTime? updatedAt;

  factory CartItemModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return CartItemModel(
      productId: data['productId'] as String? ?? doc.id,
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      addedAt: _readTimestamp(data['addedAt']),
      updatedAt: _readTimestamp(data['updatedAt']),
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
