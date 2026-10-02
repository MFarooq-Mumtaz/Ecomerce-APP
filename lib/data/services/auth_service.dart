import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.isCancellation = false});

  final String message;
  final bool isCancellation;
}

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  bool _isGoogleInitialized = false;

  User? get currentUser => _firebaseAuth.currentUser;

  void ensureRecentLoginForAccountDeletion() {
    final user = currentUser;
    final lastSignIn = user?.metadata.lastSignInTime;
    if (user == null || lastSignIn == null) {
      throw const AuthFailure('Sign in again before deleting your account.');
    }

    final age = DateTime.now().difference(lastSignIn);
    if (age.inMinutes >= 5) {
      throw const AuthFailure('Sign in again before deleting your account.');
    }
  }

  Future<void> updateDisplayName(String displayName) {
    return _firebaseAuth.currentUser?.updateDisplayName(displayName.trim()) ??
        Future<void>.value();
  }

  Future<void> deleteCurrentUser() async {
    try {
      await currentUser?.delete();
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_mapDeleteAccountMessage(error.code));
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();

    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Google Sign-In may not have an active local session.
    }
  }

  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_mapFirebaseAuthMessage(error.code));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_mapPasswordResetMessage(error.code));
    }
  }

  Future<UserCredential> createUserWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await credential.user?.updateDisplayName(displayName.trim());
      return credential;
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(
        _mapFirebaseAuthMessage(
          error.code,
          fallback: 'Sign-up failed. Please try again.',
        ),
      );
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      await _initializeGoogleSignIn();

      if (!_googleSignIn.supportsAuthenticate()) {
        throw const AuthFailure(
          'Google sign-in is not available on this device.',
        );
      }

      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw const AuthFailure(
          'Google sign-in could not be completed. Please try again.',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      return await _firebaseAuth.signInWithCredential(credential);
    } on GoogleSignInException catch (error) {
      debugPrint('Google sign-in failed: $error');
      if (_isGoogleConfigurationRejection(error)) {
        throw const AuthFailure(
          'Google sign-in is not set up for this app build yet. '
          'Please use email sign-in for now.',
        );
      }
      throw AuthFailure(
        _mapGoogleSignInMessage(error.code),
        isCancellation: error.code == GoogleSignInExceptionCode.canceled,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_mapFirebaseAuthMessage(error.code));
    }
  }

  Future<void> _initializeGoogleSignIn() async {
    if (_isGoogleInitialized) {
      return;
    }

    await _googleSignIn.initialize();
    _isGoogleInitialized = true;
  }

  String _mapFirebaseAuthMessage(
    String code, {
    String fallback = 'Sign-in failed. Please try again.',
  }) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'invalid-credential':
      case 'wrong-password':
        return 'Invalid email or password.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'network-request-failed':
        return 'Check your internet connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Choose a stronger password (at least 6 characters).';
      case 'operation-not-allowed':
        return 'Email sign-in is not enabled for this app.';
      default:
        return fallback;
    }
  }

  String _mapPasswordResetMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'network-request-failed':
        return 'Check your internet connection and try again.';
      case 'too-many-requests':
        return 'Too many requests. Please wait and try again later.';
      default:
        return 'Could not send the reset email. Please try again.';
    }
  }

  String _mapDeleteAccountMessage(String code) {
    switch (code) {
      case 'requires-recent-login':
        return 'Sign in again before deleting your account.';
      case 'network-request-failed':
        return 'Check your internet connection and try again.';
      default:
        return 'Could not delete account. Please try again.';
    }
  }

  /// Credential Manager reports "[16] Account reauth failed" as a cancel when
  /// the app's SHA-1 is not registered in Firebase. That is a setup problem,
  /// not the user closing the dialog, so it must not be hidden.
  bool _isGoogleConfigurationRejection(GoogleSignInException error) {
    if (error.code != GoogleSignInExceptionCode.canceled) {
      return false;
    }
    final description = error.description?.toLowerCase() ?? '';
    return description.contains('[16]') || description.contains('reauth');
  }

  String _mapGoogleSignInMessage(GoogleSignInExceptionCode code) {
    switch (code) {
      case GoogleSignInExceptionCode.canceled:
        return '';
      case GoogleSignInExceptionCode.clientConfigurationError:
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'Google sign-in is not configured correctly.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Google sign-in is not available right now.';
      case GoogleSignInExceptionCode.interrupted:
        return 'Google sign-in was interrupted. Please try again.';
      case GoogleSignInExceptionCode.unknownError:
      case GoogleSignInExceptionCode.userMismatch:
        return 'Google sign-in failed. Please try again.';
    }
  }
}
