import 'package:get/get.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../controller/forgot_password_controller.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgotPasswordController>(
      () => ForgotPasswordController(Get.find<AuthRepository>()),
    );
  }
}
