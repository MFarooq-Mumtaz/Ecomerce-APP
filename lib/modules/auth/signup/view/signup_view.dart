import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/unfocus_on_tap.dart';
import '../controller/signup_controller.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return UnfocusOnTap(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppLayout.pagePadding,
                  40,
                  AppLayout.pagePadding,
                  32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.textPrimary,
                        ),
                        tooltip: 'Back',
                        onPressed: controller.goBackToLogin,
                        icon: const Icon(Icons.chevron_left),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Create Account', style: AppTextStyles.headlineLarge),
                    const SizedBox(height: 31),
                    _SignupTextField(
                      controller: controller.firstNameController,
                      hintText: 'Firstname',
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    _SignupTextField(
                      controller: controller.lastNameController,
                      hintText: 'Lastname',
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    _SignupTextField(
                      controller: controller.emailController,
                      hintText: 'Email Address',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => _SignupTextField(
                        controller: controller.passwordController,
                        hintText: 'Password',
                        obscureText: !controller.isPasswordVisible.value,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => controller.signUp(),
                        suffixIcon: IconButton(
                          tooltip: controller.isPasswordVisible.value
                              ? 'Hide password'
                              : 'Show password',
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Obx(
                      () => _SignupButton(
                        isLoading: controller.isLoading.value,
                        onPressed: controller.signUp,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => _SignupMessage(
                        error: controller.errorMessage.value,
                        success: controller.successMessage.value,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: AppColors.textPrimary,
                        ),
                        onPressed: controller.goBackToLogin,
                        child: Text.rich(
                          TextSpan(
                            text: 'Already have an account ? ',
                            style: AppTextStyles.bodyMedium,
                            children: [
                              TextSpan(
                                text: 'Sign in',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignupTextField extends StatelessWidget {
  const _SignupTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppLayout.buttonHeight,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        onSubmitted: onSubmitted,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: hintText,
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class _SignupButton extends StatelessWidget {
  const _SignupButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text('Continue'),
    );
  }
}

class _SignupMessage extends StatelessWidget {
  const _SignupMessage({this.error, this.success});

  final String? error;
  final String? success;

  @override
  Widget build(BuildContext context) {
    final message = error ?? success;
    if (message == null || message.isEmpty) {
      return const SizedBox.shrink();
    }

    final isError = error != null;
    return Text(
      message,
      style: AppTextStyles.bodyMedium.copyWith(
        color: isError ? AppColors.error : AppColors.success,
      ),
    );
  }
}
