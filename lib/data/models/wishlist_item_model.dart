import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistItemModel {
  const WishlistItemModel({required this.productId, this.createdAt});

  final String productId;
  final DateTime? createdAt;

  factory WishlistItemModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return WishlistItemModel(
      productId: data['productId'] as String? ?? doc.id,
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
