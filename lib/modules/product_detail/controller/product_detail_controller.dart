import 'package:get/get.dart';

import '../../../data/models/product_model.dart';

class ProductDetailController extends GetxController {
  ProductModel? get product {
    final argument = Get.arguments;
    if (argument is ProductModel) {
      return argument;
    }
    return null;
  }
}
