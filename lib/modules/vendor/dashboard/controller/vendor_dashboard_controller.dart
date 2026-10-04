import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../data/models/order_models.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/models/vendor_model.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../data/repositories/vendor_repository.dart';
import '../../../../data/services/auth_service.dart';

enum VendorDashboardStatus { idle, loading, success, error }

class VendorDashboardController extends GetxController {
  VendorDashboardController(
    this._authService,
    this._vendorRepository,
    this._productRepository,
    this._orderRepository,
  );

  final AuthService _authService;
  final VendorRepository _vendorRepository;
  final ProductRepository _productRepository;
  final OrderRepository _orderRepository;

  final status = VendorDashboardStatus.idle.obs;
  final vendor = Rxn<VendorModel>();
  final errorMessage = RxnString();

  final productCount = 0.obs;
  final totalOrders = 0.obs;
  final unitsSold = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final user = _authService.currentUser;
    if (user == null) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    if (vendor.value == null) {
      status.value = VendorDashboardStatus.loading;
    }
    errorMessage.value = null;

    try {
      final results = await Future.wait<Object?>([
        _vendorRepository.getVendorProfile(user.uid),
        _productRepository.getVendorProducts(user.uid),
        _orderRepository.getVendorOrders(user.uid),
      ]);

      final profile = results[0] as VendorModel?;
      if (profile == null) {
        errorMessage.value = 'Store profile was not found.';
        status.value = VendorDashboardStatus.error;
        return;
      }

      final products = results[1] as List<ProductModel>;
      final orders = results[2] as List<OrderModel>;

      vendor.value = profile;
      productCount.value = products.length;
      // Every order returned here contains at least one of this vendor's
      // products; units only count this vendor's own order lines.
      totalOrders.value = orders.length;
      unitsSold.value = _countUnitsSold(orders, user.uid);
      status.value = VendorDashboardStatus.success;
    } catch (_) {
      errorMessage.value = 'Vendor dashboard could not be loaded.';
      status.value = VendorDashboardStatus.error;
    }
  }

  int _countUnitsSold(List<OrderModel> orders, String vendorId) {
    var units = 0;
    for (final order in orders) {
      for (final item in order.itemsForVendor(vendorId)) {
        units += item.quantity;
      }
    }
    return units;
  }

  void openProducts() {
    Get.toNamed(AppRoutes.vendorProducts)?.then((_) => loadDashboard());
  }

  void addProduct() {
    Get.toNamed(AppRoutes.vendorProductForm)?.then((_) => loadDashboard());
  }

  void openOrders() {
    Get.toNamed(AppRoutes.vendorOrders)?.then((_) => loadDashboard());
  }
}
