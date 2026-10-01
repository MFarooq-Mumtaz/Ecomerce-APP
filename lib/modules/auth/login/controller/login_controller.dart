import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../data/repositories/user_repository.dart';

class LoginController extends GetxController {
  LoginController(
    this._authRepository,
    this._authService,
    this._userRepository,
  );

  final AuthRepository _authRepository;
  final AuthService _authService;
  final UserRepository _userRepository;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isEmailLoading = false.obs;
  final isGoogleLoading = false.obs;
  final errorMessage = RxnString();
  final successMessage = RxnString();

  bool get _isBusy => isEmailLoading.value || isGoogleLoading.value;

  Future<void> signInWithEmailPassword() async {
    if (_isBusy) {
      return;
    }

    final validationMessage = _validateEmailPassword();
    if (validationMessage != null) {
      _showError(validationMessage);
      return;
    }

    isEmailLoading.value = true;
    _clearMessages();

    try {
      await _authRepository.signInWithEmailPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      await _routeAfterAuth();
    } on AuthFailure catch (failure) {
      _showError(failure.message);
    } on UserProfileFailure catch (failure) {
      _showError(failure.message);
    } finally {
      isEmailLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    if (_isBusy) {
      return;
    }

    isGoogleLoading.value = true;
    _clearMessages();

    try {
      await _authRepository.signInWithGoogle();
      await _routeAfterAuth();
    } on AuthFailure catch (failure) {
      if (!failure.isCancellation) {
        _showError(failure.message);
      }
    } on UserProfileFailure catch (failure) {
      _showError(failure.message);
    } finally {
      isGoogleLoading.value = false;
    }
  }

  void goToSignup() {
    FocusManager.instance.primaryFocus?.unfocus();
    Get.toNamed(AppRoutes.signup);
  }

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
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

  String? _validateEmailPassword() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty) {
      return 'Enter your email address.';
    }

    if (!GetUtils.isEmail(email)) {
      return 'Enter a valid email address.';
    }

    if (password.isEmpty) {
      return 'Enter your password.';
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
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
