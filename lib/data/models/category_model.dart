import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.isActive,
    this.imageUrl,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final String? imageUrl;
  final int sortOrder;
  final bool isActive;

  factory CategoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return CategoryModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] as bool? ?? true,
    );
  }
}
