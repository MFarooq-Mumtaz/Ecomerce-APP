import 'package:get/get.dart';

import '../../../../data/models/order_models.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../data/services/auth_service.dart';

enum VendorOrdersStatus { idle, loading, success, empty, error }

class VendorOrdersController extends GetxController {
  VendorOrdersController(this._authService, this._orderRepository);

  final AuthService _authService;
  final OrderRepository _orderRepository;

  final status = VendorOrdersStatus.idle.obs;
  final orders = <OrderModel>[].obs;
  final errorMessage = RxnString();

  /// The vendor id is the vendor's own auth uid.
  String get vendorId => _authService.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    if (vendorId.isEmpty) {
      errorMessage.value = 'Please sign in to view store orders.';
      status.value = VendorOrdersStatus.error;
      return;
    }

    status.value = VendorOrdersStatus.loading;
    errorMessage.value = null;

    try {
      final loadedOrders = await _orderRepository.getVendorOrders(vendorId);
      orders.assignAll(loadedOrders);
      status.value = loadedOrders.isEmpty
          ? VendorOrdersStatus.empty
          : VendorOrdersStatus.success;
    } catch (_) {
      errorMessage.value = 'Orders could not be loaded. Please try again.';
      status.value = VendorOrdersStatus.error;
    }
  }

  /// Only this vendor's lines are shown, even in multi-vendor orders.
  List<OrderItemSnapshot> itemsFor(OrderModel order) {
    return order.itemsForVendor(vendorId);
  }
}
