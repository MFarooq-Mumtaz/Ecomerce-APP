import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/auth_text_field.dart';
import '../controller/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

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
                top: (layout.height * 0.05).clamp(16.0, 40.0),
                bottom: 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: context.colors.surface,
                        foregroundColor: context.colors.textPrimary,
                      ),
                      tooltip: 'Back',
                      onPressed: controller.backToLogin,
                      icon: const Icon(Icons.chevron_left),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Forgot Password', style: AppTextStyles.headlineLarge),
                  const SizedBox(height: 12),
                  Text(
                    'Enter your account email and we will send you a link '
                    'to reset your password.',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: context.colors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 31),
                  Form(
                    key: controller.formKey,
                    child: AuthTextField(
                      controller: controller.emailController,
                      hintText: 'Email Address',
                      validator: AppValidators.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.email],
                      onFieldSubmitted: (_) => controller.sendResetEmail(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(
                    () => AuthSubmitButton(
                      label: 'Send Reset Link',
                      isLoading: controller.isSending.value,
                      onPressed: controller.sendResetEmail,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => AuthMessage(
                      error: controller.errorMessage.value,
                      success: controller.successMessage.value,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: context.colors.textPrimary,
                      ),
                      onPressed: controller.backToLogin,
                      child: Text(
                        'Back to Sign in',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
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
    );
  }
}
