import '../models/vendor_model.dart';
import '../services/firestore_service.dart';

class VendorFailure implements Exception {
  const VendorFailure(this.message);

  final String message;
}

class VendorRepository {
  VendorRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  Future<VendorModel?> getVendorProfile(String uid) async {
    final snapshot = await _firestoreService.getVendorDocument(uid);
    if (!snapshot.exists) {
      return null;
    }
    return VendorModel.fromFirestore(snapshot);
  }

  Future<void> convertCustomerToVendor(VendorModel vendor) async {
    try {
      await _firestoreService.convertCustomerToVendor(
        uid: vendor.ownerUid,
        vendorData: vendor.toCreateMap(),
      );
    } catch (_) {
      throw const VendorFailure(
        'Store profile could not be created. Please try again.',
      );
    }
  }
}
