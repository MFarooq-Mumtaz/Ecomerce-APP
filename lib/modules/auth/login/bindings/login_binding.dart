import 'package:get/get.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../data/services/firestore_service.dart';
import '../controller/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthService>()) {
      Get.lazyPut<AuthService>(AuthService.new);
    }
    if (!Get.isRegistered<FirestoreService>()) {
      Get.lazyPut<FirestoreService>(FirestoreService.new);
    }
    if (!Get.isRegistered<UserRepository>()) {
      Get.lazyPut<UserRepository>(
        () => UserRepository(Get.find<FirestoreService>()),
      );
    }
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(
        () =>
            AuthRepository(Get.find<AuthService>(), Get.find<UserRepository>()),
      );
    }
    Get.lazyPut<LoginController>(
      () =>
          LoginController(Get.find<AuthRepository>(), Get.find<AuthService>()),
    );
  }
}
