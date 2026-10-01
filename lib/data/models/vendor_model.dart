import 'package:cloud_firestore/cloud_firestore.dart';

class VendorModel {
  const VendorModel({
    required this.vendorId,
    required this.ownerUid,
    required this.storeName,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.description,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  final String vendorId;
  final String ownerUid;
  final String storeName;
  final String ownerName;
  final String email;
  final String phone;
  final String description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory VendorModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return VendorModel(
      vendorId: data['vendorId'] as String? ?? doc.id,
      ownerUid: data['ownerUid'] as String? ?? doc.id,
      storeName: data['storeName'] as String? ?? '',
      ownerName: data['ownerName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      description: data['description'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
      createdAt: _readTimestamp(data['createdAt']),
      updatedAt: _readTimestamp(data['updatedAt']),
    );
  }

  Map<String, Object?> toCreateMap() {
    return <String, Object?>{
      'vendorId': vendorId,
      'ownerUid': ownerUid,
      'storeName': storeName.trim(),
      'ownerName': ownerName.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'description': description.trim(),
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
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
