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
    this.vendorName,
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
  final String? vendorName;
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
      vendorName: data['vendorName'] as String?,
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
      'localImagePath': null,
      'categoryId': categoryId?.trim().isEmpty ?? true
          ? null
          : categoryId!.trim(),
      'categoryName': categoryName?.trim().isEmpty ?? true
          ? null
          : categoryName!.trim(),
      'vendorId': vendorId,
      'vendorName': vendorName?.trim().isEmpty ?? true
          ? null
          : vendorName!.trim(),
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
      'localImagePath': null,
      'categoryId': categoryId?.trim().isEmpty ?? true
          ? null
          : categoryId!.trim(),
      'categoryName': categoryName?.trim().isEmpty ?? true
          ? null
          : categoryName!.trim(),
      'vendorName': vendorName?.trim().isEmpty ?? true
          ? null
          : vendorName!.trim(),
      'stock': stock ?? 0,
      'compareAtPrice': compareAtPrice,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? localImagePath,
    String? categoryId,
    String? categoryName,
    String? vendorId,
    String? vendorName,
    int? stock,
    double? compareAtPrice,
    bool? isActive,
    int? soldCount,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      stock: stock ?? this.stock,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      isActive: isActive ?? this.isActive,
      soldCount: soldCount ?? this.soldCount,
      createdAt: createdAt ?? this.createdAt,
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
