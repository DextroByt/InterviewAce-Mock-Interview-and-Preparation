// lib/core/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // No longer needed for direct write in signUp
import 'package:flutter/foundation.dart'; // For @required and debugPrint

// This service handles all core authentication logic, interacting directly with
// Firebase Authentication for user registration, login, and session management.

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance; // No longer needed for direct write in signUp

  // Stream to listen to authentication state changes (e.g., user logged in/out)
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // --- User Registration (Sign Up) ---
  // Registers a new user with email and password.
  // The responsibility of storing initial user data in Firestore is now
  // handled by UserProfileProvider after successful registration.
  Future<User?> signUp({
    required String email,
    required String password,
    String? displayName, // Optional: for initial display name
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Update display name if provided
        if (displayName != null && displayName.isNotEmpty) {
          await user.updateDisplayName(displayName);
          debugPrint('User display name updated: ${user.displayName}');
        }
        // Removed direct Firestore write here.
        // Initial user profile data will be stored by UserProfileProvider.
        debugPrint('User signed up with Firebase Auth: ${user.uid}');
      }
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Sign Up Error: ${e.code} - ${e.message}');
      // Handle specific Firebase Auth errors
      if (e.code == 'weak-password') {
        throw AuthException('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw AuthException('An account already exists for that email.');
      }
      throw AuthException(e.message ?? 'An unknown error occurred during sign up.');
    } catch (e) {
      debugPrint('General Sign Up Error: $e');
      throw AuthException('Failed to sign up. Please try again.');
    }
  }

  // --- User Login ---
  // Logs in an existing user with email and password.
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('User signed in: ${userCredential.user?.uid}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Sign In Error: ${e.code} - ${e.message}');
      // Handle specific Firebase Auth errors
      if (e.code == 'user-not-found') {
        throw AuthException('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw AuthException('Wrong password provided for that user.');
      } else if (e.code == 'invalid-email') {
        throw AuthException('The email address is not valid.');
      }
      throw AuthException(e.message ?? 'An unknown error occurred during sign in.');
    } catch (e) {
      debugPrint('General Sign In Error: $e');
      throw AuthException('Failed to sign in. Please try again.');
    }
  }

  // --- User Logout ---
  // Signs out the current user.
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      debugPrint('User signed out.');
    } catch (e) {
      debugPrint('Sign Out Error: $e');
      throw AuthException('Failed to sign out. Please try again.');
    }
  }

  // NEW: Deletes the currently authenticated user.
  Future<void> deleteUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw AuthException('No authenticated user to delete.');
    }
    try {
      await user.delete();
      debugPrint('User account deleted.');
    } on FirebaseAuthException catch (e) {
      // Re-throw with a more user-friendly message, especially for 'requires-recent-login'
      if (e.code == 'requires-recent-login') {
        throw AuthException('Please log out and log back in to confirm your identity before deleting your account.');
      }
      throw AuthException(e.message ?? 'Failed to delete account. Please try again.');
    } catch (e) {
      debugPrint('General User Deletion Error: $e');
      throw AuthException('An unexpected error occurred during account deletion.');
    }
  }

  // --- Get Current User ---
  // Returns the currently logged-in Firebase User object.
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // NEW: Method to send a password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      debugPrint('Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Password Reset Error: ${e.code} - ${e.message}');
      if (e.code == 'invalid-email') {
        throw AuthException('The email address is not valid.');
      } else if (e.code == 'user-not-found') {
        // We throw a generic message here to prevent leaking user information.
        throw AuthException('Could not find a user with that email. Please try again.');
      }
      throw AuthException(e.message ?? 'An unexpected error occurred while sending the reset email.');
    } catch (e) {
      debugPrint('General Password Reset Error: $e');
      throw AuthException('An unexpected error occurred. Please try again.');
    }
  }
}

// Custom exception class for authentication errors
// Moved outside AuthService to be a top-level class
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
