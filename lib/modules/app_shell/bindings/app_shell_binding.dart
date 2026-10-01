import 'package:get/get.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/vendor_repository.dart';
import '../../../data/repositories/wishlist_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/firestore_service.dart';
import '../../../data/services/local_product_image_service.dart';
import '../../cart/controller/cart_controller.dart';
import '../../collection/controller/collection_controller.dart';
import '../../home/controller/home_controller.dart';
import '../../profile/controller/profile_controller.dart';
import '../../wishlist/controller/wishlist_controller.dart';
import '../controller/app_shell_controller.dart';

class AppShellBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FirestoreService>()) {
      Get.lazyPut<FirestoreService>(FirestoreService.new, fenix: true);
    }
    if (!Get.isRegistered<LocalProductImageService>()) {
      Get.lazyPut<LocalProductImageService>(
        LocalProductImageService.new,
        fenix: true,
      );
    }
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
    if (!Get.isRegistered<CartRepository>()) {
      Get.lazyPut<CartRepository>(
        () => CartRepository(
          Get.find<FirestoreService>(),
          Get.find<ProductRepository>(),
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<VendorRepository>()) {
      Get.lazyPut<VendorRepository>(
        () => VendorRepository(Get.find<FirestoreService>()),
        fenix: true,
      );
    }
    Get.lazyPut<AppShellController>(AppShellController.new);
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<ProductRepository>()),
    );
    if (!Get.isRegistered<CollectionController>()) {
      Get.lazyPut<CollectionController>(
        () => CollectionController(Get.find<ProductRepository>()),
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
    if (!Get.isRegistered<CartController>()) {
      Get.lazyPut<CartController>(
        () =>
            CartController(Get.find<CartRepository>(), Get.find<AuthService>()),
      );
    }
    if (!Get.isRegistered<ProfileController>()) {
      Get.lazyPut<ProfileController>(
        () => ProfileController(
          Get.find<AuthService>(),
          Get.find<AuthRepository>(),
          Get.find<UserRepository>(),
        ),
      );
    }
  }
}
