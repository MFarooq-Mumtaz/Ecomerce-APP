import 'package:get/get.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/address_repository.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/vendor_repository.dart';
import '../../data/repositories/wishlist_repository.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/cloudinary_service.dart';
import '../../data/services/firestore_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(AuthService.new, fenix: true);
    Get.lazyPut<FirestoreService>(FirestoreService.new, fenix: true);
    Get.lazyPut<CloudinaryService>(CloudinaryService.new, fenix: true);
    Get.lazyPut<UserRepository>(
      () => UserRepository(Get.find<FirestoreService>()),
      fenix: true,
    );
    Get.lazyPut<ProductRepository>(
      () => ProductRepository(Get.find<FirestoreService>()),
      fenix: true,
    );
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(Get.find<AuthService>(), Get.find<UserRepository>()),
      fenix: true,
    );
    Get.lazyPut<WishlistRepository>(
      () => WishlistRepository(
        Get.find<FirestoreService>(),
        Get.find<ProductRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut<CartRepository>(
      () => CartRepository(
        Get.find<FirestoreService>(),
        Get.find<ProductRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut<AddressRepository>(
      () => AddressRepository(Get.find<FirestoreService>()),
      fenix: true,
    );
    Get.lazyPut<OrderRepository>(
      () => OrderRepository(Get.find<FirestoreService>()),
      fenix: true,
    );
    Get.lazyPut<VendorRepository>(
      () => VendorRepository(Get.find<FirestoreService>()),
      fenix: true,
    );
  }
}
