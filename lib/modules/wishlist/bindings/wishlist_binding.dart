import 'package:get/get.dart';

import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/wishlist_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/firestore_service.dart';
import '../controller/wishlist_controller.dart';

class WishlistBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProductRepository>()) {
      Get.lazyPut<ProductRepository>(
        () => ProductRepository(Get.find<FirestoreService>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<WishlistRepository>()) {
      Get.lazyPut<WishlistRepository>(
        () => WishlistRepository(
          Get.find<FirestoreService>(),
          Get.find<ProductRepository>(),
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<WishlistController>()) {
      Get.lazyPut<WishlistController>(
        () => WishlistController(
          Get.find<WishlistRepository>(),
          Get.find<AuthService>(),
        ),
      );
    }
  }
}
