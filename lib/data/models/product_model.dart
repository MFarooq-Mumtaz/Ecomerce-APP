import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.isActive,
    this.description = '',
    this.imageUrl,
    this.localImagePath,
    this.categoryId,
    this.categoryName,
    this.vendorId,
    this.stock,
    this.compareAtPrice,
    this.soldCount = 0,
    this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String? localImagePath;
  final String? categoryId;
  final String? categoryName;
  final String? vendorId;
  final int? stock;
  final double? compareAtPrice;
  final bool isActive;
  final int soldCount;
  final DateTime? createdAt;

  factory ProductModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return ProductModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      imageUrl: data['imageUrl'] as String?,
      localImagePath: data['localImagePath'] as String?,
      categoryId: data['categoryId'] as String?,
      categoryName: data['categoryName'] as String?,
      vendorId: data['vendorId'] as String?,
      stock: (data['stock'] as num?)?.toInt(),
      compareAtPrice: (data['compareAtPrice'] as num?)?.toDouble(),
      isActive: data['isActive'] as bool? ?? true,
      // Older seeded products may not have soldCount yet, so treat it as 0.
      soldCount: (data['soldCount'] as num?)?.toInt() ?? 0,
      createdAt: _readTimestamp(data['createdAt']),
    );
  }

  Map<String, Object?> toCreateMap({required String vendorId}) {
    return <String, Object?>{
      'name': name.trim(),
      'description': description.trim(),
      'price': price,
      'imageUrl': imageUrl?.trim().isEmpty ?? true ? null : imageUrl!.trim(),
      'localImagePath': localImagePath?.trim().isEmpty ?? true
          ? null
          : localImagePath!.trim(),
      'categoryId': categoryId?.trim().isEmpty ?? true
          ? null
          : categoryId!.trim(),
      'categoryName': categoryName?.trim().isEmpty ?? true
          ? null
          : categoryName!.trim(),
      'vendorId': vendorId,
      'stock': stock ?? 0,
      'compareAtPrice': compareAtPrice,
      'isActive': isActive,
      'soldCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, Object?> toUpdateMap() {
    return <String, Object?>{
      'name': name.trim(),
      'description': description.trim(),
      'price': price,
      'imageUrl': imageUrl?.trim().isEmpty ?? true ? null : imageUrl!.trim(),
      'localImagePath': localImagePath?.trim().isEmpty ?? true
          ? null
          : localImagePath!.trim(),
      'categoryId': categoryId?.trim().isEmpty ?? true
          ? null
          : categoryId!.trim(),
      'categoryName': categoryName?.trim().isEmpty ?? true
          ? null
          : categoryName!.trim(),
      'stock': stock ?? 0,
      'compareAtPrice': compareAtPrice,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
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
