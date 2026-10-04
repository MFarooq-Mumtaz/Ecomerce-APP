import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/auth_text_field.dart';
import '../controller/signup_controller.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

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
                      onPressed: controller.goBackToLogin,
                      icon: const Icon(Icons.chevron_left),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Create Account', style: AppTextStyles.headlineLarge),
                  const SizedBox(height: 31),
                  Form(
                    key: controller.formKey,
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AuthTextField(
                            controller: controller.firstNameController,
                            hintText: 'Firstname',
                            validator: AppValidators.required(
                              'Please enter your first name.',
                            ),
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.givenName],
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            controller: controller.lastNameController,
                            hintText: 'Lastname',
                            validator: AppValidators.required(
                              'Please enter your last name.',
                            ),
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.familyName],
                          ),
                          const SizedBox(height: 16),
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
                              validator: AppValidators.newPassword,
                              obscureText: !controller.isPasswordVisible.value,
                              onToggleVisibility:
                                  controller.togglePasswordVisibility,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.newPassword],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => AuthTextField(
                              controller: controller.confirmPasswordController,
                              hintText: 'Confirm Password',
                              validator: AppValidators.confirmPassword(
                                () => controller.passwordController.text,
                              ),
                              obscureText:
                                  !controller.isConfirmPasswordVisible.value,
                              onToggleVisibility:
                                  controller.toggleConfirmPasswordVisibility,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => controller.signUp(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Obx(
                    () => AuthSubmitButton(
                      label: 'Continue',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.signUp,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => AuthMessage(error: controller.errorMessage.value)),
                  const SizedBox(height: 28),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: context.colors.textPrimary,
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
    );
  }
}
