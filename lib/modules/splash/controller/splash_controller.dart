import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/services/auth_service.dart';

class SplashController extends GetxController {
  SplashController(this._authService, this._userRepository);

  final AuthService _authService;
  final UserRepository _userRepository;

  @override
  void onReady() {
    super.onReady();
    _routeFromSession();
  }

  Future<void> _routeFromSession() async {
    final user = _authService.currentUser;
    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (Get.currentRoute != AppRoutes.splash) {
      return;
    }

    if (user == null) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    // Customers and vendors both land on the normal customer Home.
    // Vendors open their dashboard manually from Profile > Manage Store.
    try {
      await _userRepository.ensureCustomerProfileExists(user);
    } catch (_) {
      // Home can still render catalog data while profile recovery is retried
      // by the next successful auth flow.
    }

    Get.offAllNamed(AppRoutes.home);
  }
}
