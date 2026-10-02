import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../services/firestore_service.dart';

class UserProfileFailure implements Exception {
  const UserProfileFailure(this.message);

  final String message;
}

class UserRepository {
  UserRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  Future<void> createInitialCustomerProfile({
    required User user,
    required String displayName,
  }) async {
    try {
      final wasCreated = await _createCustomerProfileIfMissing(
        user: user,
        displayName: displayName,
      );

      if (!wasCreated) {
        throw StateError('User profile already exists.');
      }
    } catch (_) {
      throw const UserProfileFailure(
        'Account created, but profile setup failed. Please try again.',
      );
    }
  }

  Future<void> ensureCustomerProfileExists(
    User? user, {
    String? fallbackDisplayName,
  }) async {
    if (user == null) {
      throw const UserProfileFailure('Unable to load the signed-in user.');
    }

    try {
      await _createCustomerProfileIfMissing(
        user: user,
        displayName: _resolveDisplayName(user, fallbackDisplayName),
      );
    } on UserProfileFailure {
      rethrow;
    } catch (_) {
      throw const UserProfileFailure('Profile setup failed. Please try again.');
    }
  }

  Future<UserModel> getUserProfile(String uid) async {
    try {
      final profile = await _firestoreService.getUserDocument(uid);
      if (!profile.exists) {
        throw const UserProfileFailure('User profile was not found.');
      }

      return UserModel.fromFirestore(profile);
    } on UserProfileFailure {
      rethrow;
    } catch (_) {
      throw const UserProfileFailure('Unable to load user profile.');
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    required String displayName,
    required String? photoUrl,
  }) async {
    try {
      await _firestoreService.updateUserProfile(
        uid: uid,
        displayName: displayName,
        photoUrl: photoUrl,
      );
    } catch (_) {
      throw const UserProfileFailure('Unable to update user profile.');
    }
  }

  Future<void> deleteUserOwnedData(String uid) async {
    try {
      await _firestoreService.deleteUserOwnedData(uid);
    } catch (_) {
      throw const UserProfileFailure('Unable to delete user data.');
    }
  }

  Future<bool> _createCustomerProfileIfMissing({
    required User user,
    required String displayName,
  }) {
    final userModel = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: displayName.trim(),
      photoUrl: user.photoURL,
      role: UserModel.customerRole,
      vendorId: null,
      isActive: true,
    );

    return _firestoreService.createUserDocumentIfMissing(
      uid: user.uid,
      data: userModel.toCreateMap(),
    );
  }

  String _resolveDisplayName(User user, String? fallbackDisplayName) {
    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final fallback = fallbackDisplayName?.trim();
    if (fallback != null && fallback.isNotEmpty) {
      return fallback;
    }

    return user.email?.split('@').first ?? 'MIRA Customer';
  }
}
