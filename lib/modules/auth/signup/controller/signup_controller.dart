import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/services/auth_service.dart';

class SignupController extends GetxController {
  SignupController(
    this._authRepository,
    this._authService,
    this._userRepository,
  );

  final AuthRepository _authRepository;
  final AuthService _authService;
  final UserRepository _userRepository;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final successMessage = RxnString();

  Future<void> signUp() async {
    if (isLoading.value) {
      return;
    }

    final validationMessage = _validate();
    if (validationMessage != null) {
      _showError(validationMessage);
      return;
    }

    isLoading.value = true;
    _clearMessages();

    try {
      await _authRepository.signUpWithEmailPassword(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      await _routeAfterAuth();
    } on AuthFailure catch (failure) {
      _showError(failure.message);
    } on UserProfileFailure catch (failure) {
      _showError(failure.message);
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  void goBackToLogin() {
    FocusManager.instance.primaryFocus?.unfocus();
    Get.back();
  }

  Future<void> _routeAfterAuth() async {
    final user = _authService.currentUser;
    if (user == null) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    final profile = await _userRepository.getUserProfile(user.uid);
    Get.offAllNamed(
      profile.isVendor ? AppRoutes.vendorDashboard : AppRoutes.home,
    );
  }

  String? _validate() {
    if (firstNameController.text.trim().isEmpty) {
      return 'Enter your first name.';
    }

    if (lastNameController.text.trim().isEmpty) {
      return 'Enter your last name.';
    }

    final email = emailController.text.trim();
    if (email.isEmpty) {
      return 'Enter your email address.';
    }

    if (!GetUtils.isEmail(email)) {
      return 'Enter a valid email address.';
    }

    if (passwordController.text.isEmpty) {
      return 'Enter your password.';
    }

    if (passwordController.text.length < 6) {
      return 'Use at least 6 characters for your password.';
    }

    return null;
  }

  void _clearMessages() {
    errorMessage.value = null;
    successMessage.value = null;
  }

  void _showError(String message) {
    successMessage.value = null;
    errorMessage.value = message;
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
