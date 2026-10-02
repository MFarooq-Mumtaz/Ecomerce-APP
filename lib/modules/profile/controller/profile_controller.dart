import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/cloudinary_service.dart';
import '../../cart/controller/cart_controller.dart';
import '../../wishlist/controller/wishlist_controller.dart';

enum ProfileLoadStatus { idle, loading, success, error }

class ProfileController extends GetxController {
  ProfileController(
    this._authService,
    this._authRepository,
    this._userRepository,
    this._cloudinaryService,
  );

  final AuthService _authService;
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final CloudinaryService _cloudinaryService;
  final _imagePicker = ImagePicker();

  final displayNameController = TextEditingController();
  final status = ProfileLoadStatus.idle.obs;
  final isSaving = false.obs;
  final isPickingPhoto = false.obs;
  final isLoggingOut = false.obs;
  final isDeletingAccount = false.obs;
  final user = Rxn<UserModel>();
  final errorMessage = RxnString();
  final pickedPhotoPath = RxnString();

  String? get previewPhotoUrl => pickedPhotoPath.value ?? user.value?.photoUrl;

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
      pickedPhotoPath.value = null;
      status.value = ProfileLoadStatus.success;
    } catch (_) {
      errorMessage.value = 'Profile could not be loaded. Please try again.';
      status.value = ProfileLoadStatus.error;
    }
  }

  Future<void> pickProfilePhoto() async {
    if (isPickingPhoto.value) {
      return;
    }

    isPickingPhoto.value = true;
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 86,
      );
      if (image == null) {
        return;
      }
      pickedPhotoPath.value = image.path;
    } catch (_) {
      AppSnackbar.show('Profile photo', 'Could not open image picker.');
    } finally {
      isPickingPhoto.value = false;
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
      final pickedPath = pickedPhotoPath.value;
      String? uploadedPhotoUrl;
      if (pickedPath != null && pickedPath.isNotEmpty) {
        uploadedPhotoUrl = (await _cloudinaryService.uploadProfileImage(
          pickedPath,
        )).secureUrl;
      }

      await _userRepository.updateUserProfile(
        uid: firebaseUser.uid,
        displayName: displayName,
        photoUrl: uploadedPhotoUrl ?? currentProfile.photoUrl,
      );
      await _authService.updateDisplayName(displayName);
      await loadProfile();
      AppSnackbar.show('Profile', 'Profile updated.');
    } on CloudinaryUploadFailure catch (failure) {
      AppSnackbar.show('Profile photo', failure.message);
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

  Future<void> confirmDeleteAccount() async {
    if (isDeletingAccount.value) {
      return;
    }

    final shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This will delete your profile, cart, wishlist, addresses and your '
          'vendor products. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await deleteAccount();
    }
  }

  Future<void> deleteAccount() async {
    if (isDeletingAccount.value) {
      return;
    }

    isDeletingAccount.value = true;
    try {
      Get.find<WishlistController>().clearSession();
      Get.find<CartController>().clearSession();
      await _authRepository.deleteCurrentAccount();
      clearSession();
      if (Get.isRegistered<WishlistController>()) {
        Get.delete<WishlistController>(force: true);
      }
      if (Get.isRegistered<CartController>()) {
        Get.delete<CartController>(force: true);
      }
      Get.offAllNamed(AppRoutes.login);
      AppSnackbar.show('Account', 'Account deleted.');
    } on AuthFailure catch (failure) {
      AppSnackbar.show('Account', failure.message);
    } catch (_) {
      AppSnackbar.show('Account', 'Could not delete account. Try again.');
    } finally {
      isDeletingAccount.value = false;
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
    pickedPhotoPath.value = null;
    errorMessage.value = null;
    status.value = ProfileLoadStatus.idle;
    isDeletingAccount.value = false;
  }

  @override
  void onClose() {
    displayNameController.dispose();
    super.onClose();
  }
}
