import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  Future<void> sendLinkToEmail(String email) async {
    final actionCodeSettings = ActionCodeSettings(
      url: 'https://calopulse.web.app',
      handleCodeInApp: true,
      androidPackageName: 'com.example.calo_pulse',
      androidInstallApp: true,
      iOSBundleId: 'com.example.caloPulse',
    );
    try {
      await _firebaseAuth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  Future<UserCredential> verifyLink({
    required String email,
    required String emailLink,
  }) {
    final cred = EmailAuthProvider.credentialWithLink(
      email: email,
      emailLink: emailLink,
    );
    try {
      return _firebaseAuth.signInWithCredential(cred);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Exception _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return Exception('Invalid email address.');
      case 'user-disabled':
        return Exception('User account is disabled.');
      case 'user-not-found':
        return Exception('No user found for this email.');
      case 'wrong-password':
        return Exception('Incorrect password.');
      case 'email-already-in-use':
        return Exception('Email is already in use.');
      case 'operation-not-allowed':
        return Exception('Operation not allowed. Contact support.');
      case 'weak-password':
        return Exception('Password is too weak.');
      default:
        return Exception('Authentication error: ${e.message}');
    }
  }
}
