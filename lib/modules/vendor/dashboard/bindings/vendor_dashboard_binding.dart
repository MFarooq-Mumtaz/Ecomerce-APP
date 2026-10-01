import 'package:get/get.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/vendor_repository.dart';
import '../../../../data/services/auth_service.dart';
import '../controller/vendor_dashboard_controller.dart';

class VendorDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorDashboardController>(
      () => VendorDashboardController(
        Get.find<AuthService>(),
        Get.find<AuthRepository>(),
        Get.find<VendorRepository>(),
      ),
    );
  }
}
