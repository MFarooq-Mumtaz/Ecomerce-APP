import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/services/auth_service.dart';

class SignupController extends GetxController {
  SignupController(this._authRepository, this._authService);

  final AuthRepository _authRepository;
  final AuthService _authService;

  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> signUp() async {
    if (isLoading.value) {
      return;
    }

    errorMessage.value = null;
    // Firebase signup only runs after every field passes validation.
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;

    try {
      await _authRepository.signUpWithEmailPassword(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      Get.offAllNamed(
        _authService.currentUser == null ? AppRoutes.login : AppRoutes.home,
      );
    } on AuthFailure catch (failure) {
      errorMessage.value = failure.message;
    } on UserProfileFailure catch (failure) {
      errorMessage.value = failure.message;
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.toggle();
  }

  void goBackToLogin() {
    FocusManager.instance.primaryFocus?.unfocus();
    Get.back();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
