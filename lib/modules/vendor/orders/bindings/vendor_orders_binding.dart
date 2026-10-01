import 'package:get/get.dart';

import '../../../../data/repositories/order_repository.dart';
import '../../../../data/services/auth_service.dart';
import '../controller/vendor_orders_controller.dart';

class VendorOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorOrdersController>(
      () => VendorOrdersController(
        Get.find<AuthService>(),
        Get.find<OrderRepository>(),
      ),
    );
  }
}
