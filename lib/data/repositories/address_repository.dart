import '../models/address_model.dart';
import '../services/firestore_service.dart';

class AddressRepository {
  AddressRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  Future<List<AddressModel>> getAddresses(String uid) async {
    final snapshot = await _firestoreService.getAddressDocuments(uid);
    final addresses = snapshot.docs.map(AddressModel.fromFirestore).toList();
    addresses.sort((a, b) {
      if (a.isDefault == b.isDefault) {
        return a.fullName.compareTo(b.fullName);
      }
      return a.isDefault ? -1 : 1;
    });
    return addresses;
  }

  Future<String> createAddress({
    required String uid,
    required AddressModel address,
    required bool makeDefault,
  }) {
    return _firestoreService.createAddress(
      uid: uid,
      data: address.toCreateMap(),
      makeDefault: makeDefault,
    );
  }
}
