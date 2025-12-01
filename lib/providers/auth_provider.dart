// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/services/auth_service.dart';
import '../core/services/storage_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  // FIX: Use the singleton instance of StorageService.
  final StorageService _storageService = StorageService();

  User? _currentUser;
  UserModel? _loggedInUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  UserModel? get loggedInUser => _loggedInUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  AuthProvider()
      : _authService = AuthService() {
    _initAuthListener();
    _loadUserFromStorage();
  }

  void _initAuthListener() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      _currentUser = firebaseUser;
      _isAuthenticated = firebaseUser != null;
      debugPrint('Auth State Changed: User is ${firebaseUser != null ? 'logged in' : 'logged out'}');

      if (firebaseUser != null) {
        _loggedInUser = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User',
          createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
          lastLoginAt: firebaseUser.metadata.lastSignInTime,
        );
        await _storageService.saveUserProfile(_loggedInUser!.toJson());
        debugPrint('Basic UserModel created/updated from Firebase User and saved locally.');
      } else {
        _loggedInUser = null;
        // FIX: Removed clearUserSession as it's not used.
        await _storageService.clearUserProfile();
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserFromStorage() async {
    // FIX: No need to init() here, the service manages its own initialization.
    final userProfileJson = await _storageService.getUserProfile();
    if (userProfileJson != null) {
      try {
        _loggedInUser = UserModel.fromJson(userProfileJson);
        debugPrint('User profile pre-loaded from local storage.');
      } catch (e) {
        debugPrint('Error loading user profile from storage: $e');
        _loggedInUser = null;
      }
    }
    notifyListeners();
  }

  // ... other methods remain the same

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signIn(email: email, password: password);
      debugPrint('Login successful for $email');
    } on AuthException catch (e) {
      debugPrint('Login failed: ${e.message}');
      if (FirebaseAuth.instance.currentUser != null) {
        debugPrint('Warning: Login reported error but Firebase user is active. Proceeding as successful.');
      } else {
        rethrow;
      }
    } catch (e) {
      debugPrint('Unexpected login error: $e');
      throw AuthException('An unexpected error occurred during login.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signup(String email, String password, {String? displayName}) async {
    _setLoading(true);
    try {
      await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      debugPrint('Sign up successful for $email');
    } on AuthException catch (e) {
      debugPrint('Sign up failed: ${e.message}');
      if (FirebaseAuth.instance.currentUser != null) {
        debugPrint('Warning: Signup reported error but Firebase user is active. Proceeding as successful.');
      } else {
        rethrow;
      }
    } catch (e) {
      debugPrint('Unexpp error: $e');
      throw AuthException('An unexpected signuected error occurred during sign up.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      debugPrint('Logout successful.');
    } on AuthException catch (e) {
      debugPrint('Logout failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected logout error: $e');
      throw AuthException('An unexpected error occurred during logout.');
    } finally {
      _setLoading(false);
    }
  }

  // NEW: Method to send a password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    try {
      await _authService.sendPasswordResetEmail(email);
      debugPrint('Password reset email sent via AuthService.');
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // NEW: Method to delete the authenticated user's account.
  Future<void> deleteAccount() async {
    _setLoading(true);
    try {
      await _authService.deleteUser();
      debugPrint('User account deleted via AuthService.');
    } on AuthException catch (e) {
      debugPrint('Account deletion failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected account deletion error: $e');
      throw AuthException('An unexpected error occurred during account deletion.');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
