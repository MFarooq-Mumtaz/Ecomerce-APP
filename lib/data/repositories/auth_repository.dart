import 'package:firebase_auth/firebase_auth.dart';

import 'user_repository.dart';
import '../services/auth_service.dart';

class AuthRepository {
  AuthRepository(this._authService, this._userRepository);

  final AuthService _authService;
  final UserRepository _userRepository;

  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _authService.signInWithEmailPassword(
      email: email,
      password: password,
    );

    await _userRepository.ensureCustomerProfileExists(credential.user);
    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    final credential = await _authService.signInWithGoogle();
    await _userRepository.ensureCustomerProfileExists(credential.user);
    return credential;
  }

  Future<UserCredential> signUpWithEmailPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final displayName = '$firstName $lastName'.trim();
    final credential = await _authService.createUserWithEmailPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
    final user = credential.user;
    if (user == null) {
      throw const UserProfileFailure('Unable to load the created user.');
    }

    await _userRepository.createInitialCustomerProfile(
      user: user,
      displayName: displayName,
    );
    return credential;
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _authService.sendPasswordResetEmail(email);
  }

  Future<void> signOut() {
    return _authService.signOut();
  }
}
