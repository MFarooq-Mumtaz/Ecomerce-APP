import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.isActive,
    this.photoUrl,
    this.vendorId,
    this.createdAt,
    this.updatedAt,
  });

  static const customerRole = 'customer';
  static const vendorRole = 'vendor';

  final String uid;
  final String email;
  final String displayName;
  final String role;
  final String? photoUrl;
  final String? vendorId;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isVendor => role == vendorRole && vendorId == uid;

  factory UserModel.fromMap(Map<String, dynamic> data, {String? fallbackUid}) {
    return UserModel(
      uid: data['uid'] as String? ?? fallbackUid ?? '',
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      role: data['role'] as String? ?? customerRole,
      photoUrl: data['photoUrl'] as String?,
      vendorId: data['vendorId'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: _readTimestamp(data['createdAt']),
      updatedAt: _readTimestamp(data['updatedAt']),
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return UserModel.fromMap(data, fallbackUid: doc.id);
  }

  Map<String, dynamic> toCreateMap() {
    return <String, dynamic>{
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': customerRole,
      'vendorId': null,
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
