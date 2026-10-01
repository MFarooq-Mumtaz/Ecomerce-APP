import 'package:firebase_auth/firebase_auth.dart';
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

  Future<void> updateDisplayName(String displayName) {
    return _firebaseAuth.currentUser?.updateDisplayName(displayName.trim()) ??
        Future<void>.value();
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
      throw AuthFailure(_mapFirebaseAuthMessage(error.code));
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

  String _mapFirebaseAuthMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Email or password is incorrect.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'network-request-failed':
        return 'Check your internet connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Choose a stronger password.';
      default:
        return 'Sign-in failed. Please try again.';
    }
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
