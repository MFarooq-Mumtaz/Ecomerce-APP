import 'package:get/get.dart';

import '../../../../data/repositories/vendor_repository.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../data/services/firestore_service.dart';
import '../controller/become_vendor_controller.dart';

class BecomeVendorBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<VendorRepository>()) {
      Get.lazyPut<VendorRepository>(
        () => VendorRepository(Get.find<FirestoreService>()),
        fenix: true,
      );
    }
    Get.lazyPut<BecomeVendorController>(
      () => BecomeVendorController(
        Get.find<AuthService>(),
        Get.find<VendorRepository>(),
      ),
    );
  }
}
