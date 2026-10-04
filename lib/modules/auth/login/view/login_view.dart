import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_layout.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/auth_text_field.dart';
import '../controller/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, layout) => Center(
            child: SingleChildScrollView(
              // Content stays at most 440 wide and centered on tablets; the
              // top gap shrinks on short (landscape) screens.
              padding: layout.pageInsets(
                maxContentWidth: Responsive.authMaxWidth,
                top: (layout.height * 0.1).clamp(16.0, 92.0),
                bottom: 32,
              ),
              child: Form(
                key: controller.formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Sign in', style: AppTextStyles.headlineLarge),
                      const SizedBox(height: 31),
                      AuthTextField(
                        controller: controller.emailController,
                        hintText: 'Email Address',
                        validator: AppValidators.email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => AuthTextField(
                          controller: controller.passwordController,
                          hintText: 'Password',
                          validator: AppValidators.loginPassword,
                          obscureText: !controller.isPasswordVisible.value,
                          onToggleVisibility:
                              controller.togglePasswordVisibility,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onFieldSubmitted: (_) =>
                              controller.signInWithEmailPassword(),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: context.colors.textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: controller.goToForgotPassword,
                          child: Text(
                            'Forgot Password?',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(
                        () => AuthSubmitButton(
                          label: 'Continue',
                          isLoading: controller.isEmailLoading.value,
                          onPressed: controller.signInWithEmailPassword,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => AuthMessage(error: controller.errorMessage.value),
                      ),
                      const SizedBox(height: 12),
                      _CreateAccountPrompt(onTap: controller.goToSignup),
                      const SizedBox(height: 44),
                      Obx(
                        () => _GoogleLoginButton(
                          isLoading: controller.isGoogleLoading.value,
                          onPressed: controller.signInWithGoogle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateAccountPrompt extends StatelessWidget {
  const _CreateAccountPrompt({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        style: TextButton.styleFrom(
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: context.colors.textPrimary,
          textStyle: AppTextStyles.bodyMedium,
        ),
        onPressed: onTap,
        child: Text.rich(
          TextSpan(
            text: "Don't have an Account? ",
            style: AppTextStyles.bodyMedium.copyWith(
              color: context.colors.textMuted,
            ),
            children: [
              TextSpan(
                text: 'Create One',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleLoginButton extends StatelessWidget {
  const _GoogleLoginButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: context.colors.surface,
          foregroundColor: context.colors.textPrimary,
          disabledBackgroundColor: context.colors.surface,
          disabledForegroundColor: context.colors.textMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppLayout.pillRadius),
          ),
          textStyle: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/images/auth/google.png',
                width: 24,
                height: 24,
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Text('Continue With Google'),
          ],
        ),
      ),
    );
  }
}
