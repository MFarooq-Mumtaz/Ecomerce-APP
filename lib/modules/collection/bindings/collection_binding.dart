import 'package:get/get.dart';

import '../../../data/repositories/product_repository.dart';
import '../../../data/services/firestore_service.dart';
import '../controller/collection_controller.dart';

class CollectionBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProductRepository>()) {
      Get.lazyPut<ProductRepository>(
        () => ProductRepository(Get.find<FirestoreService>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<CollectionController>()) {
      Get.lazyPut<CollectionController>(
        () => CollectionController(Get.find<ProductRepository>()),
      );
    }
  }
}
