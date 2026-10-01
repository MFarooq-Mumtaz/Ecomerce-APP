import 'package:get/get.dart';

import '../../../data/repositories/cart_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/firestore_service.dart';
import '../controller/cart_controller.dart';

class CartBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProductRepository>()) {
      Get.lazyPut<ProductRepository>(
        () => ProductRepository(Get.find<FirestoreService>()),
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
    if (!Get.isRegistered<CartController>()) {
      Get.lazyPut<CartController>(
        () =>
            CartController(Get.find<CartRepository>(), Get.find<AuthService>()),
      );
    }
  }
}
