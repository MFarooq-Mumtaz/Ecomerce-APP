import 'package:get/get.dart';

import '../../../../data/repositories/product_repository.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../data/services/local_product_image_service.dart';
import '../controller/vendor_product_form_controller.dart';
import '../controller/vendor_products_controller.dart';

class VendorProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorProductsController>(
      () => VendorProductsController(
        Get.find<AuthService>(),
        Get.find<ProductRepository>(),
        Get.find<LocalProductImageService>(),
      ),
    );
  }
}

class VendorProductFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorProductFormController>(
      () => VendorProductFormController(
        Get.find<AuthService>(),
        Get.find<ProductRepository>(),
        Get.find<LocalProductImageService>(),
      ),
    );
  }
}
