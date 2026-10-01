import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Text field used by Login, Signup and Forgot Password.
///
/// Pass [onToggleVisibility] for password fields to show the eye icon.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.controller,
    required this.hintText,
    super.key,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.onToggleVisibility,
    this.onFieldSubmitted,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hintText;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(4);

    return TextFormField(
      controller: controller,
      validator: validator,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      obscureText: obscureText,
      autocorrect: !obscureText,
      enableSuggestions: !obscureText,
      onFieldSubmitted: onFieldSubmitted,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 18,
        ),
        errorStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
        suffixIcon: onToggleVisibility == null
            ? null
            : IconButton(
                tooltip: obscureText ? 'Show password' : 'Hide password',
                onPressed: onToggleVisibility,
                icon: Icon(
                  obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}

/// Inline error/success line shown under auth forms.
class AuthMessage extends StatelessWidget {
  const AuthMessage({super.key, this.error, this.success});

  final String? error;
  final String? success;

  @override
  Widget build(BuildContext context) {
    final message = error ?? success;
    if (message == null || message.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      message,
      style: AppTextStyles.bodyMedium.copyWith(
        color: error != null ? AppColors.error : AppColors.success,
      ),
    );
  }
}

/// Primary pill button with a loading spinner, shared by the auth screens.
class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
    super.key,
  });

  final String label;
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
          : Text(label),
    );
  }
}
