import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/services/auth_service.dart';

class ForgotPasswordController extends GetxController {
  ForgotPasswordController(this._authRepository);

  final AuthRepository _authRepository;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  final isSending = false.obs;
  final errorMessage = RxnString();
  final successMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    // Login passes the email the user already typed, if any.
    final argument = Get.arguments;
    if (argument is String) {
      emailController.text = argument;
    }
  }

  Future<void> sendResetEmail() async {
    if (isSending.value) {
      return;
    }

    errorMessage.value = null;
    successMessage.value = null;
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    isSending.value = true;

    try {
      await _authRepository.sendPasswordResetEmail(emailController.text.trim());
      successMessage.value =
          'Password reset email sent. Please check your inbox.';
    } on AuthFailure catch (failure) {
      errorMessage.value = failure.message;
    } catch (_) {
      errorMessage.value = 'Could not send the reset email. Please try again.';
    } finally {
      isSending.value = false;
    }
  }

  void backToLogin() {
    FocusManager.instance.primaryFocus?.unfocus();
    Get.back();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
