import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../data/models/vendor_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/vendor_repository.dart';
import '../../../../data/services/auth_service.dart';
import '../../../cart/controller/cart_controller.dart';
import '../../../profile/controller/profile_controller.dart';
import '../../../wishlist/controller/wishlist_controller.dart';

enum VendorDashboardStatus { idle, loading, success, error }

class VendorDashboardController extends GetxController {
  VendorDashboardController(
    this._authService,
    this._authRepository,
    this._vendorRepository,
  );

  final AuthService _authService;
  final AuthRepository _authRepository;
  final VendorRepository _vendorRepository;

  final status = VendorDashboardStatus.idle.obs;
  final vendor = Rxn<VendorModel>();
  final errorMessage = RxnString();
  final isLoggingOut = false.obs;

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

    status.value = VendorDashboardStatus.loading;
    errorMessage.value = null;

    try {
      final profile = await _vendorRepository.getVendorProfile(user.uid);
      if (profile == null) {
        errorMessage.value = 'Store profile was not found.';
        status.value = VendorDashboardStatus.error;
        return;
      }

      vendor.value = profile;
      status.value = VendorDashboardStatus.success;
    } catch (_) {
      errorMessage.value = 'Vendor dashboard could not be loaded.';
      status.value = VendorDashboardStatus.error;
    }
  }

  void openProducts() {
    Get.toNamed(AppRoutes.vendorProducts);
  }

  void addProduct() {
    Get.toNamed(AppRoutes.vendorProductForm);
  }

  void browseCustomerApp() {
    Get.toNamed(AppRoutes.home);
  }

  Future<void> logout() async {
    if (isLoggingOut.value) {
      return;
    }

    isLoggingOut.value = true;
    try {
      if (Get.isRegistered<WishlistController>()) {
        Get.find<WishlistController>().clearSession();
      }
      if (Get.isRegistered<CartController>()) {
        Get.find<CartController>().clearSession();
      }
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().clearSession();
      }
      await _authRepository.signOut();
      Get.offAllNamed(AppRoutes.login);
    } catch (_) {
      Get.snackbar('Logout', 'Could not logout. Try again.');
    } finally {
      isLoggingOut.value = false;
    }
  }
}
