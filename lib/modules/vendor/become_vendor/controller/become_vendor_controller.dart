import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/phone_number_field.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../data/models/vendor_model.dart';
import '../../../../data/repositories/vendor_repository.dart';
import '../../../../data/services/auth_service.dart';
import '../../../profile/controller/profile_controller.dart';

class BecomeVendorController extends GetxController {
  BecomeVendorController(this._authService, this._vendorRepository);

  final AuthService _authService;
  final VendorRepository _vendorRepository;

  final storeNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final descriptionController = TextEditingController();
  final isSubmitting = false.obs;

  /// Latest value from the phone field, including the country code.
  PhoneNumber? _phone;

  @override
  void onInit() {
    super.onInit();
    final user = _authService.currentUser;
    ownerNameController.text = user?.displayName?.trim() ?? '';
    emailController.text = user?.email ?? '';
  }

  void onPhoneChanged(PhoneNumber phone) {
    _phone = phone;
  }

  Future<void> submit() async {
    final user = _authService.currentUser;
    if (user == null || isSubmitting.value) {
      return;
    }

    final validation = _validate();
    if (validation != null) {
      AppSnackbar.show('Become a Vendor', validation);
      return;
    }

    isSubmitting.value = true;
    try {
      final vendor = VendorModel(
        vendorId: user.uid,
        ownerUid: user.uid,
        storeName: storeNameController.text.trim(),
        ownerName: ownerNameController.text.trim(),
        email: emailController.text.trim(),
        // Saved in international format, e.g. +923001234567.
        phone: _phone!.completeNumber,
        description: descriptionController.text.trim(),
        isActive: true,
      );
      await _vendorRepository.convertCustomerToVendor(vendor);
      if (Get.isRegistered<ProfileController>()) {
        await Get.find<ProfileController>().loadProfile();
      }
      // Stay in the normal customer app; Profile now shows Manage Store.
      Get.closeAllSnackbars();
      Get.back();
      AppSnackbar.show(
        'Become a Vendor',
        'Your store is ready. Open it from Profile > Manage Store.',
      );
    } on VendorFailure catch (failure) {
      AppSnackbar.show('Become a Vendor', failure.message);
    } catch (_) {
      AppSnackbar.show(
        'Become a Vendor',
        'Could not submit request. Try again.',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  String? _validate() {
    if (storeNameController.text.trim().isEmpty) {
      return 'Enter store name.';
    }
    if (ownerNameController.text.trim().isEmpty) {
      return 'Enter owner name.';
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      return 'Enter a valid contact email.';
    }
    final phoneError = AppValidators.phone(_phone);
    if (phoneError != null) {
      return phoneError;
    }
    if (descriptionController.text.trim().length < 10) {
      return 'Enter a short store description.';
    }
    return null;
  }

  @override
  void onClose() {
    storeNameController.dispose();
    ownerNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
