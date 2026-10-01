import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/services/auth_service.dart';

class LoginController extends GetxController {
  LoginController(this._authRepository, this._authService);

  final AuthRepository _authRepository;
  final AuthService _authService;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isEmailLoading = false.obs;
  final isGoogleLoading = false.obs;
  final errorMessage = RxnString();

  bool get _isBusy => isEmailLoading.value || isGoogleLoading.value;

  Future<void> signInWithEmailPassword() async {
    if (_isBusy) {
      return;
    }

    errorMessage.value = null;
    // Inline validation runs first; Firebase is never called with bad input.
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    isEmailLoading.value = true;

    try {
      await _authRepository.signInWithEmailPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      _routeAfterAuth();
    } on AuthFailure catch (failure) {
      errorMessage.value = failure.message;
    } on UserProfileFailure catch (failure) {
      errorMessage.value = failure.message;
    } finally {
      isEmailLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    if (_isBusy) {
      return;
    }

    isGoogleLoading.value = true;
    errorMessage.value = null;

    try {
      await _authRepository.signInWithGoogle();
      _routeAfterAuth();
    } on AuthFailure catch (failure) {
      if (!failure.isCancellation) {
        errorMessage.value = failure.message;
      }
    } on UserProfileFailure catch (failure) {
      errorMessage.value = failure.message;
    } finally {
      isGoogleLoading.value = false;
    }
  }

  void goToSignup() {
    FocusManager.instance.primaryFocus?.unfocus();
    Get.toNamed(AppRoutes.signup);
  }

  void goToForgotPassword() {
    FocusManager.instance.primaryFocus?.unfocus();
    Get.toNamed(
      AppRoutes.forgotPassword,
      arguments: emailController.text.trim(),
    );
  }

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  /// Customers and vendors both land on Home after login.
  void _routeAfterAuth() {
    if (_authService.currentUser == null) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
