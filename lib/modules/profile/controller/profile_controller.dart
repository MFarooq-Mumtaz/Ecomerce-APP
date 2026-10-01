import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../cart/controller/cart_controller.dart';
import '../../wishlist/controller/wishlist_controller.dart';

enum ProfileLoadStatus { idle, loading, success, error }

class ProfileController extends GetxController {
  ProfileController(
    this._authService,
    this._authRepository,
    this._userRepository,
  );

  final AuthService _authService;
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  final displayNameController = TextEditingController();
  final status = ProfileLoadStatus.idle.obs;
  final isSaving = false.obs;
  final isLoggingOut = false.obs;
  final user = Rxn<UserModel>();
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser == null) {
      clearSession();
      return;
    }

    status.value = ProfileLoadStatus.loading;
    errorMessage.value = null;

    try {
      final profile = await _userRepository.getUserProfile(firebaseUser.uid);
      user.value = profile;
      displayNameController.text = _displayName(profile);
      status.value = ProfileLoadStatus.success;
    } catch (_) {
      errorMessage.value = 'Profile could not be loaded. Please try again.';
      status.value = ProfileLoadStatus.error;
    }
  }

  Future<void> saveDisplayName() async {
    final firebaseUser = _authService.currentUser;
    final currentProfile = user.value;
    if (firebaseUser == null || currentProfile == null || isSaving.value) {
      return;
    }

    final displayName = displayNameController.text.trim();
    if (displayName.isEmpty) {
      AppSnackbar.show('Profile', 'Display name cannot be empty.');
      return;
    }

    isSaving.value = true;
    try {
      await _userRepository.updateUserProfile(
        uid: firebaseUser.uid,
        displayName: displayName,
        photoUrl: currentProfile.photoUrl,
      );
      await _authService.updateDisplayName(displayName);
      await loadProfile();
      AppSnackbar.show('Profile', 'Profile updated.');
    } catch (_) {
      AppSnackbar.show('Profile', 'Could not update profile. Try again.');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> logout() async {
    if (isLoggingOut.value) {
      return;
    }

    isLoggingOut.value = true;
    try {
      Get.find<WishlistController>().clearSession();
      Get.find<CartController>().clearSession();
      clearSession();
      await _authRepository.signOut();
      if (Get.isRegistered<WishlistController>()) {
        Get.delete<WishlistController>(force: true);
      }
      if (Get.isRegistered<CartController>()) {
        Get.delete<CartController>(force: true);
      }
      Get.offAllNamed(AppRoutes.login);
    } catch (_) {
      AppSnackbar.show('Logout', 'Could not logout. Try again.');
    } finally {
      isLoggingOut.value = false;
    }
  }

  String _displayName(UserModel profile) {
    final displayName = profile.displayName.trim();
    if (displayName.isNotEmpty) {
      return displayName;
    }

    return profile.email.split('@').first;
  }

  void clearSession() {
    user.value = null;
    displayNameController.clear();
    errorMessage.value = null;
    status.value = ProfileLoadStatus.idle;
  }

  @override
  void onClose() {
    displayNameController.dispose();
    super.onClose();
  }
}
