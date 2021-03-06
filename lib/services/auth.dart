import 'package:firebase_auth/firebase_auth.dart';

// Authentication Controller
// Part of TIMELIST JOURNAL (by Logan Giese)

class Auth {
  static final _auth = FirebaseAuth.instance;

  static Future<String> signInWithEmailAndPassword(
      {String email, String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (err) {
      return _parseSignInAuthException(err);
    }
    return null;
  }

  static Future<String> createAccountWithEmailAndPassword(
      {String email, String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (err) {
      return _parseCreateAccountAuthException(err);
    }
    return null;
  }

  static String getUserId() {
    return _auth.currentUser.uid;
  }

  static bool isSignedIn() {
    return (_auth.currentUser != null);
  }

  static Future<void> signOut() {
    return _auth.signOut();
  }

  static String _parseSignInAuthException(FirebaseAuthException exception) {
    print(exception.code);
    switch (exception.code) {
      case 'invalid-email':
        return 'Email address is not formatted correctly';
      case 'user-not-found':
      case 'wrong-password':
      case 'user-disabled':
        return 'Invalid username or password';
      case 'too-many-requests':
      case 'operation-not-allowed':
      default:
        return 'An unknown error occurred';
    }
  }

  static String _parseCreateAccountAuthException(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Email address is not formatted correctly';
      case 'email-already-in-use':
        return 'This email address is already in use';
      default:
        return 'An unknown error occurred';
    }
  }

}
