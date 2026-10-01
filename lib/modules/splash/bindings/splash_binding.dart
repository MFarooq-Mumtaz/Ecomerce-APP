import 'package:get/get.dart';

import '../../../data/repositories/user_repository.dart';
import '../../../data/services/auth_service.dart';
import '../controller/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(
      SplashController(Get.find<AuthService>(), Get.find<UserRepository>()),
    );
  }
}
