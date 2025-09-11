import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _userProfile;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // Getters
  User? get currentUser => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isApproved => _userProfile?['isApproved'] ?? false;

  void _onAuthStateChanged(User? user) {
    _user = user;
    if (user != null) {
      _loadUserProfile();
    } else {
      _userProfile = null;
    }
    notifyListeners();
  }

  Future<void> _loadUserProfile() async {
    if (_user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        _userProfile = doc.data();
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load user profile: $e';
      notifyListeners();
    }
  }

  // Sign up with email and password
  Future<bool> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String role, // 'user', 'caregiver', 'business'
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user profile in Firestore
        await _createUserProfile(
          uid: credential.user!.uid,
          email: email,
          fullName: fullName,
          role: role,
        );
        return true;
      }
      return false;
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _error = null;

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Check if user profile exists, if not create one
        final doc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!doc.exists) {
          await _createUserProfile(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email!,
            fullName: userCredential.user!.displayName ?? '',
            role: 'user',
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Create user profile in Firestore
  Future<void> _createUserProfile({
    required String uid,
    required String email,
    required String fullName,
    required String role,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'fullName': fullName,
      'role': role,
      'isApproved': false, // Requires admin approval
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'contributionCount': 0,
      'accessibilityPreferences': {
        'wheelchairAccessible': false,
        'brailleSupport': false,
        'hearingAssistance': false,
        'visualAssistance': false,
      },
    });
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      _error = _getErrorMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _error = null;
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'weak-password':
          return 'Password is too weak.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'too-many-requests':
          return 'Too many failed attempts. Please try again later.';
        default:
          return error.message ?? 'An authentication error occurred.';
      }
    }
    return 'An unexpected error occurred.';
  }
}
