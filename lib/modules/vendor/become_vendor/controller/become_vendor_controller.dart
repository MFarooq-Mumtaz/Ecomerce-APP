import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
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

  @override
  void onInit() {
    super.onInit();
    final user = _authService.currentUser;
    ownerNameController.text = user?.displayName?.trim() ?? '';
    emailController.text = user?.email ?? '';
  }

  Future<void> submit() async {
    final user = _authService.currentUser;
    if (user == null || isSubmitting.value) {
      return;
    }

    final validation = _validate();
    if (validation != null) {
      Get.snackbar('Become a Vendor', validation);
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
        phone: phoneController.text.trim(),
        description: descriptionController.text.trim(),
        isActive: true,
      );
      await _vendorRepository.convertCustomerToVendor(vendor);
      if (Get.isRegistered<ProfileController>()) {
        await Get.find<ProfileController>().loadProfile();
      }
      Get.offAllNamed(AppRoutes.vendorDashboard);
      Get.snackbar('Become a Vendor', 'Your store is ready.');
    } on VendorFailure catch (failure) {
      Get.snackbar('Become a Vendor', failure.message);
    } catch (_) {
      Get.snackbar('Become a Vendor', 'Could not submit request. Try again.');
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
    if (phoneController.text.trim().isEmpty) {
      return 'Enter phone number.';
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
