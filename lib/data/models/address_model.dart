import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  const AddressModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.isDefault,
    this.addressLine2,
  });

  final String id;
  final String fullName;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;

  factory AddressModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return AddressModel(
      id: doc.id,
      fullName: data['fullName'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      addressLine1: data['addressLine1'] as String? ?? '',
      addressLine2: data['addressLine2'] as String?,
      city: data['city'] as String? ?? '',
      state: data['state'] as String? ?? '',
      postalCode: data['postalCode'] as String? ?? '',
      country: data['country'] as String? ?? '',
      isDefault: data['isDefault'] as bool? ?? false,
    );
  }

  factory AddressModel.fromMap(Map<String, dynamic> data, {String id = ''}) {
    return AddressModel(
      id: id,
      fullName: data['fullName'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      addressLine1: data['addressLine1'] as String? ?? '',
      addressLine2: data['addressLine2'] as String?,
      city: data['city'] as String? ?? '',
      state: data['state'] as String? ?? '',
      postalCode: data['postalCode'] as String? ?? '',
      country: data['country'] as String? ?? '',
      isDefault: data['isDefault'] as bool? ?? false,
    );
  }

  Map<String, Object?> toCreateMap() {
    return <String, Object?>{
      'fullName': fullName.trim(),
      'phone': phone.trim(),
      'addressLine1': addressLine1.trim(),
      'addressLine2': addressLine2?.trim(),
      'city': city.trim(),
      'state': state.trim(),
      'postalCode': postalCode.trim(),
      'country': country.trim(),
      'isDefault': isDefault,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, Object?> toOrderSnapshot() {
    return <String, Object?>{
      'fullName': fullName,
      'phone': phone,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
    };
  }

  String get summary {
    final optionalLine = addressLine2?.trim();
    final parts = <String>[
      addressLine1,
      if (optionalLine != null && optionalLine.isNotEmpty) optionalLine,
      city,
      state,
      postalCode,
      country,
    ].where((part) => part.trim().isNotEmpty);

    return parts.join(', ');
  }
}
