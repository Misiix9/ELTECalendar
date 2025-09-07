// File: lib/services/auth_service.dart
// Purpose: Complete authentication service with Firebase integration
// Step: 2.1 - Authentication System Implementation

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart'; // TODO: Re-enable when fixing dependency issues
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io' show Platform;

import '../models/user_model.dart';
import '../utils/constants.dart';
import 'firebase_service.dart';

/// Comprehensive authentication service implementing all specified requirements
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // TODO: Fix GoogleSignIn constructor - temporarily disabled
  // final GoogleSignIn _googleSignIn = GoogleSignIn(
  //   scopes: ['email', 'profile'],
  // );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _firebaseService = FirebaseService();

  StudentUser? _currentUser;
  UserAuthState _authState = UserAuthState.unknown;
  String? _lastError;

  /// Current authenticated user
  StudentUser? get currentUser => _currentUser;

  /// Current authentication state
  UserAuthState get authState => _authState;

  /// Last authentication error
  String? get lastError => _lastError;

  /// Current Firebase user
  User? get firebaseUser => _auth.currentUser;

  /// Check if user is currently authenticated
  bool get isAuthenticated => _authState == UserAuthState.authenticated;

  /// Check if email verification is required (non-blocking as specified)
  bool get isEmailVerificationRequired => 
      _authState == UserAuthState.emailNotVerified;

  /// Initialize authentication service and listen to auth state changes
  Future<void> initialize() async {
    try {
      // Listen to Firebase Auth state changes
      _auth.authStateChanges().listen(_onAuthStateChanged);
      
      // Check current auth state
      await _checkCurrentAuthState();
      
      if (kDebugMode) {
        print('AuthService initialized successfully');
      }
    } catch (e) {
      _lastError = 'Failed to initialize authentication: $e';
      if (kDebugMode) {
        print(_lastError);
      }
      rethrow;
    }
  }

  /// Handle Firebase Auth state changes
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    try {
      if (firebaseUser == null) {
        // User signed out
        _currentUser = null;
        _authState = UserAuthState.unauthenticated;
      } else {
        // User signed in - load or create user profile
        await _loadUserProfile(firebaseUser);
        
        // Update authentication state based on email verification
        if (firebaseUser.emailVerified || !AppConstants.requireEmailVerification) {
          _authState = UserAuthState.authenticated;
        } else {
          _authState = UserAuthState.emailNotVerified;
        }
      }
      
      notifyListeners();
    } catch (e) {
      _lastError = 'Error handling auth state change: $e';
      _authState = UserAuthState.unknown;
      notifyListeners();
      
      if (kDebugMode) {
        print(_lastError);
      }
    }
  }

  /// Check current authentication state on app startup
  Future<void> _checkCurrentAuthState() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      await _onAuthStateChanged(firebaseUser);
    } else {
      _authState = UserAuthState.unauthenticated;
      notifyListeners();
    }
  }

  /// Load user profile from Firestore or create new one
  Future<void> _loadUserProfile(User firebaseUser) async {
    try {
      try {
        final userDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(firebaseUser.uid)
            .collection(AppConstants.profileSubcollection)
            .doc('profile')
            .get()
            .timeout(const Duration(seconds: 10));

        if (userDoc.exists) {
          // Load existing user profile
          final userData = userDoc.data()!;
          _currentUser = StudentUser(
            uid: firebaseUser.uid,
            email: userData['email'] ?? firebaseUser.email ?? '',
            displayName: userData['displayName'] ?? firebaseUser.displayName ?? '',
            emailVerified: firebaseUser.emailVerified,
            createdAt: (userData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            currentSemester: userData['currentSemester'] ?? StudentUser.calculateCurrentSemester(),
            lastLoginAt: DateTime.now(),
            profileImageUrl: userData['profileImageUrl'] ?? firebaseUser.photoURL,
            preferences: Map<String, dynamic>.from(userData['preferences'] ?? {}),
          );
          
          // Update last login time (non-blocking)
          _updateLastLoginTime().catchError((e) {
            if (kDebugMode) print('Warning: Could not update last login time: $e');
          });
        } else {
          // Create new user profile
          await _createUserProfile(firebaseUser);
        }
      } catch (firestoreError) {
        if (kDebugMode) {
          print('Warning: Firestore not available, creating basic user profile: $firestoreError');
        }
        // Create basic user profile without Firestore
        _currentUser = StudentUser.fromAuth(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? '',
          emailVerified: firebaseUser.emailVerified,
          profileImageUrl: firebaseUser.photoURL,
        );
      }
      
    } catch (e) {
      _lastError = 'Failed to load user profile: $e';
      if (kDebugMode) print(_lastError);
      // Create minimal user profile so app doesn't fail
      _currentUser = StudentUser.fromAuth(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? '',
        emailVerified: firebaseUser.emailVerified,
        profileImageUrl: firebaseUser.photoURL,
      );
    }
  }

  /// Create new user profile in Firestore
  Future<void> _createUserProfile(User firebaseUser) async {
    try {
      _currentUser = StudentUser.fromAuth(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? '',
        emailVerified: firebaseUser.emailVerified,
        profileImageUrl: firebaseUser.photoURL,
      );

      // Try to save profile to Firestore with timeout
      try {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(firebaseUser.uid)
            .collection(AppConstants.profileSubcollection)
            .doc('profile')
            .set(_currentUser!.toFirestore())
            .timeout(const Duration(seconds: 10));

        if (kDebugMode) {
          print('New user profile created for ${firebaseUser.email}');
        }
      } catch (firestoreError) {
        if (kDebugMode) {
          print('Warning: Could not save profile to Firestore: $firestoreError');
        }
        // Continue without Firestore - user can still use the app
      }
    } catch (e) {
      _lastError = 'Failed to create user profile: $e';
      throw Exception(_lastError);
    }
  }

  /// Update user's last login time
  Future<void> _updateLastLoginTime() async {
    if (_currentUser == null) return;

    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_currentUser!.uid)
          .collection(AppConstants.profileSubcollection)
          .doc('profile')
          .update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Non-critical error, don't throw
      if (kDebugMode) {
        print('Failed to update last login time: $e');
      }
    }
  }

  /// Register with email and password
  Future<AuthResult> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _lastError = null;

      // Validate input
      if (!UserProfileValidator.isValidEmail(email)) {
        return AuthResult.failure('Invalid email format');
      }

      if (!UserProfileValidator.isValidPassword(password)) {
        return AuthResult.failure('Password must be at least 6 characters');
      }

      if (!UserProfileValidator.isValidDisplayName(displayName)) {
        return AuthResult.failure('Display name must be at least 2 characters');
      }

      // Create Firebase Auth account
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(displayName);

        // Send email verification (non-blocking as specified)
        if (!credential.user!.emailVerified && AppConstants.requireEmailVerification) {
          await sendEmailVerification();
        }

        // Reload user to get updated info
        await credential.user!.reload();

        return AuthResult.success('Registration successful');
      } else {
        return AuthResult.failure('Registration failed - no user created');
      }
    } on FirebaseAuthException catch (e) {
      _lastError = _getFirebaseAuthErrorMessage(e);
      return AuthResult.failure(_lastError!);
    } catch (e) {
      _lastError = 'Registration failed: $e';
      return AuthResult.failure(_lastError!);
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _lastError = null;

      // Validate input
      if (!UserProfileValidator.isValidEmail(email)) {
        return AuthResult.failure('Invalid email format');
      }

      if (password.isEmpty) {
        return AuthResult.failure('Password is required');
      }

      // Sign in with Firebase Auth
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        return AuthResult.success('Login successful');
      } else {
        return AuthResult.failure('Login failed - no user found');
      }
    } on FirebaseAuthException catch (e) {
      _lastError = _getFirebaseAuthErrorMessage(e);
      return AuthResult.failure(_lastError!);
    } catch (e) {
      _lastError = 'Login failed: $e';
      return AuthResult.failure(_lastError!);
    }
  }

  /// Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      _lastError = null;

      // TODO: Fix Google Sign-In dependency issues
      return AuthResult.failure('Google sign-in temporarily disabled - dependency issues');

      // Trigger Google Sign In
      // final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      // if (googleUser == null) {
      //   // User cancelled the sign-in
      //   return AuthResult.failure('Google sign-in cancelled');
      // }

      // Get authentication details
      // final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create Firebase credential
      // final OAuthCredential credential = GoogleAuthProvider.credential(
      //   accessToken: googleAuth.accessToken,
      //   idToken: googleAuth.idToken,
      // );

      // Sign in with credential
      // final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // if (userCredential.user != null) {
      //   return AuthResult.success('Google sign-in successful');
      // } else {
      //   return AuthResult.failure('Google sign-in failed');
      // }
    } on FirebaseAuthException catch (e) {
      _lastError = _getFirebaseAuthErrorMessage(e);
      return AuthResult.failure(_lastError!);
    } catch (e) {
      _lastError = 'Google sign-in failed: $e';
      return AuthResult.failure(_lastError!);
    }
  }

  /// Sign in with Apple (iOS only)
  Future<AuthResult> signInWithApple() async {
    try {
      _lastError = null;

      // Check if Apple Sign In is available (iOS only)
      if (!Platform.isIOS) {
        return AuthResult.failure('Apple Sign-In is only available on iOS');
      }

      if (!await SignInWithApple.isAvailable()) {
        return AuthResult.failure('Apple Sign-In is not available');
      }

      // Request Apple ID credential
      final AuthorizationCredentialAppleID appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential for Firebase
      final OAuthCredential credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in with Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Update display name if available from Apple
        if (appleCredential.givenName != null || appleCredential.familyName != null) {
          final displayName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
          if (displayName.isNotEmpty) {
            await userCredential.user!.updateDisplayName(displayName);
          }
        }

        return AuthResult.success('Apple sign-in successful');
      } else {
        return AuthResult.failure('Apple sign-in failed');
      }
    } on FirebaseAuthException catch (e) {
      _lastError = _getFirebaseAuthErrorMessage(e);
      return AuthResult.failure(_lastError!);
    } catch (e) {
      _lastError = 'Apple sign-in failed: $e';
      return AuthResult.failure(_lastError!);
    }
  }

  /// Send email verification (non-blocking as specified)
  Future<AuthResult> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user signed in');
      }

      if (user.emailVerified) {
        return AuthResult.success('Email already verified');
      }

      await user.sendEmailVerification();
      return AuthResult.success('Verification email sent');
    } on FirebaseAuthException catch (e) {
      _lastError = _getFirebaseAuthErrorMessage(e);
      return AuthResult.failure(_lastError!);
    } catch (e) {
      _lastError = 'Failed to send verification email: $e';
      return AuthResult.failure(_lastError!);
    }
  }

  /// Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      _lastError = null;

      if (!UserProfileValidator.isValidEmail(email)) {
        return AuthResult.failure('Invalid email format');
      }

      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult.success('Password reset email sent');
    } on FirebaseAuthException catch (e) {
      _lastError = _getFirebaseAuthErrorMessage(e);
      return AuthResult.failure(_lastError!);
    } catch (e) {
      _lastError = 'Failed to send password reset email: $e';
      return AuthResult.failure(_lastError!);
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      _lastError = null;

      // Sign out from Firebase Auth
      await _auth.signOut();
      
      // TODO: Add Google Sign-In signout when GoogleSignIn is properly configured
      // await _googleSignIn.signOut();

      // Clear local user data
      _currentUser = null;
      _authState = UserAuthState.unauthenticated;
      
      notifyListeners();

      if (kDebugMode) {
        print('User signed out successfully');
      }
    } catch (e) {
      _lastError = 'Sign out failed: $e';
      if (kDebugMode) {
        print(_lastError);
      }
    }
  }

  /// Delete user account (with confirmation)
  Future<AuthResult> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user signed in');
      }

      // Delete user data from Firestore first
      await _firebaseService.deleteUserData(user.uid);

      // Delete Firebase Auth user
      await user.delete();

      // Clear local state
      _currentUser = null;
      _authState = UserAuthState.unauthenticated;
      notifyListeners();

      return AuthResult.success('Account deleted successfully');
    } on FirebaseAuthException catch (e) {
      _lastError = _getFirebaseAuthErrorMessage(e);
      return AuthResult.failure(_lastError!);
    } catch (e) {
      _lastError = 'Failed to delete account: $e';
      return AuthResult.failure(_lastError!);
    }
  }

  /// Update user profile
  Future<AuthResult> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user signed in');
      }

      // Update Firebase Auth profile
      await user.updateDisplayName(displayName);
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      // Update Firestore profile
      final updateData = <String, dynamic>{};
      if (displayName != null) updateData['displayName'] = displayName;
      if (photoURL != null) updateData['profileImageUrl'] = photoURL;
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .collection(AppConstants.profileSubcollection)
          .doc('profile')
          .update(updateData);

      // Update local user object
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          displayName: displayName ?? _currentUser!.displayName,
          profileImageUrl: photoURL ?? _currentUser!.profileImageUrl,
        );
        notifyListeners();
      }

      return AuthResult.success('Profile updated successfully');
    } catch (e) {
      _lastError = 'Failed to update profile: $e';
      return AuthResult.failure(_lastError!);
    }
  }

  /// Get user preference
  T getUserPreference<T>(String key, T defaultValue) {
    return _currentUser?.getPreference(key, defaultValue) ?? defaultValue;
  }

  /// Update user preference
  Future<void> updateUserPreference(String key, dynamic value) async {
    if (_currentUser == null) return;

    try {
      // Update local user object
      _currentUser = _currentUser!.updatePreference(key, value);
      notifyListeners();

      // Update Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_currentUser!.uid)
          .collection(AppConstants.profileSubcollection)
          .doc('profile')
          .update({
        'preferences.$key': value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update user preference: $e');
      }
    }
  }

  /// Check if user is currently logged in
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null && isAuthenticated;
  }

  /// Get current user ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Convert Firebase Auth exceptions to user-friendly messages
  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action';
      default:
        return e.message ?? 'Authentication failed';
    }
  }

  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
}

/// Authentication result wrapper
class AuthResult {
  final bool success;
  final String message;

  const AuthResult._({required this.success, required this.message});

  factory AuthResult.success(String message) => AuthResult._(success: true, message: message);
  factory AuthResult.failure(String message) => AuthResult._(success: false, message: message);
}