import 'package:get/get.dart';

import '../../../data/repositories/address_repository.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/firestore_service.dart';
import '../../cart/controller/cart_controller.dart';
import '../controller/checkout_controller.dart';

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AddressRepository>()) {
      Get.lazyPut<AddressRepository>(
        () => AddressRepository(Get.find<FirestoreService>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<OrderRepository>()) {
      Get.lazyPut<OrderRepository>(
        () => OrderRepository(Get.find<FirestoreService>()),
        fenix: true,
      );
    }
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
    Get.lazyPut<CheckoutController>(
      () => CheckoutController(
        Get.find<AuthService>(),
        Get.find<AddressRepository>(),
        Get.find<OrderRepository>(),
        Get.find<CartController>(),
      ),
    );
  }
}
