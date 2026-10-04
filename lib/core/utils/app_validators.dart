import 'package:get/get.dart';
import 'package:intl_phone_field/phone_number.dart';

/// Form validators shared across the app's forms.
abstract final class AppValidators {
  /// Firebase Auth rejects passwords shorter than 6 characters.
  static const minPasswordLength = 6;

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Please enter your email.';
    }
    if (!GetUtils.isEmail(email)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password.';
    }
    return null;
  }

  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password.';
    }
    if (value.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters.';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() password) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your password.';
      }
      if (value != password()) {
        return 'Passwords do not match.';
      }
      return null;
    };
  }

  /// Phone numbers come from [PhoneNumberField], which includes the country
  /// code. Returns an error message, or null when the length is valid for
  /// the selected country.
  static String? phone(PhoneNumber? phone) {
    if (phone == null || phone.number.trim().isEmpty) {
      return 'Enter phone number.';
    }
    try {
      phone.isValidNumber();
      return null;
    } catch (_) {
      return 'Enter a valid phone number.';
    }
  }

  static String? Function(String?) required(String message) {
    return (value) => (value?.trim().isEmpty ?? true) ? message : null;
  }
}
