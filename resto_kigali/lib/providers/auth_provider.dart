import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String? _userDisplayName;
  String? _userPhoneNumber;
  bool _notificationsEnabled = true;
  bool _isLoading = false;
  bool _profileLoaded = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  String? get userDisplayName => _userDisplayName;
  String? get userPhoneNumber => _userPhoneNumber;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;
  bool get isEmailVerified => _user?.emailVerified ?? false;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Create user account
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _user = userCredential.user;

      // Update profile
      await _user?.updateDisplayName(displayName);
      _userDisplayName = displayName;
      _userPhoneNumber = phoneNumber;

      // Create user profile in Firestore using UID
      if (_user != null) {
        await _firestore.collection('users').doc(_user!.uid).set({
          'uid': _user!.uid,
          'email': email.trim(),
          'displayName': displayName,
          'phoneNumber': phoneNumber,
          'notificationsEnabled': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Send email verification
      await _user?.sendEmailVerification();

      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _user = userCredential.user;
      _userDisplayName = _user?.displayName;
      _userPhoneNumber = _user?.phoneNumber;

      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firebaseAuth.signOut();

      _user = null;
      _userDisplayName = null;
      _userPhoneNumber = null;
      _profileLoaded = false;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Load user profile information from Firestore
  Future<void> loadUserProfile() async {
    if (_profileLoaded) return;
    _profileLoaded = true;
    try {
      _user = _firebaseAuth.currentUser;
      _userDisplayName = _user?.displayName;
      _userPhoneNumber = _user?.phoneNumber;

      // Load additional profile data from Firestore
      if (_user != null) {
        final doc = await _firestore.collection('users').doc(_user!.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          _userDisplayName = data['displayName']?.toString() ?? _userDisplayName;
          _userPhoneNumber = data['phoneNumber']?.toString() ?? _userPhoneNumber;
          final notif = data['notificationsEnabled'];
          _notificationsEnabled = (notif != false);
        }
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load profile: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Update notification preferences via Firestore
  Future<void> updateNotificationPreference(bool value) async {
    try {
      final userId = _user?.uid;
      if (userId == null) return;

      await _firestore.collection('users').doc(userId).set({
        'notificationsEnabled': value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _notificationsEnabled = value;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update preferences: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Resend email verification
  Future<void> resendEmailVerification() async {
    try {
      await _user?.sendEmailVerification();
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Update user email
  Future<void> updateEmail(String newEmail) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _user?.verifyBeforeUpdateEmail(newEmail.trim());

      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
