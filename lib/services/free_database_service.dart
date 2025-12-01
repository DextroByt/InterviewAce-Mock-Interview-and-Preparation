// lib/services/free_database_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // To get current user UID
import 'package:flutter/foundation.dart'; // For debugPrint

// This service handles all interactions with Firestore, including saving and
// retrieving user profiles and interview history, adhering to the specified
// data paths for public and private data in the Canvas environment.

class FreeDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Global variables provided by the Canvas environment for app-specific paths
  // Corrected initialization for Dart. __app_id is a global variable provided by the Canvas runtime.
  final String _appId = const String.fromEnvironment('APP_ID', defaultValue: 'default-app-id');


  // Helper to get the current authenticated user's UID.
  // If no user is authenticated, it generates a random UUID for temporary use
  // or throws an error if a user-specific operation is attempted without authentication.
  String? get _currentUserId {
    // In a real app, you'd ensure the user is authenticated before calling this.
    // For Canvas environment, __initial_auth_token handles initial auth.
    return _auth.currentUser?.uid;
  }

  // --- User Profile Management (Private Data) ---
  // Path: /artifacts/{appId}/users/{userId}/user_profiles/{documentId}
  Future<void> saveUserProfile(String userId, Map<String, dynamic> userData) async {
    if (_currentUserId == null || _currentUserId != userId) {
      debugPrint('Error: Unauthorized attempt to save user profile for $userId.');
      throw DatabaseException('Unauthorized: Cannot save profile for another user.');
    }
    try {
      final docRef = _firestore.collection('artifacts').doc(_appId).collection('users').doc(userId).collection('user_profiles').doc(userId);
      await docRef.set(userData, SetOptions(merge: true)); // Use merge to update existing fields
      debugPrint('User profile saved to Firestore for UID: $userId');
    } catch (e) {
      debugPrint('Error saving user profile to Firestore: $e');
      throw DatabaseException('Failed to save user profile: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    if (_currentUserId == null || _currentUserId != userId) {
      debugPrint('Error: Unauthorized attempt to get user profile for $userId.');
      throw DatabaseException('Unauthorized: Cannot access profile of another user.');
    }
    try {
      final docSnapshot = await _firestore.collection('artifacts').doc(_appId).collection('users').doc(userId).collection('user_profiles').doc(userId).get();
      if (docSnapshot.exists) {
        debugPrint('User profile fetched from Firestore for UID: $userId');
        return docSnapshot.data();
      }
      debugPrint('User profile not found in Firestore for UID: $userId');
      return null;
    } catch (e) {
      debugPrint('Error getting user profile from Firestore: $e');
      throw DatabaseException('Failed to retrieve user profile: $e');
    }
  }

  // --- Interview History Management (Private Data) ---
  // Path: /artifacts/{appId}/users/{userId}/interview_history/{documentId}
  Future<void> addInterviewHistory(String userId, Map<String, dynamic> interviewData) async {
    if (_currentUserId == null || _currentUserId != userId) {
      debugPrint('Error: Unauthorized attempt to add interview history for $userId.');
      throw DatabaseException('Unauthorized: Cannot add history for another user.');
    }
    try {
      // Firestore automatically generates a document ID if you use add()
      await _firestore.collection('artifacts').doc(_appId).collection('users').doc(userId).collection('interview_history').add(interviewData);
      debugPrint('Interview history added to Firestore for UID: $userId');
    } catch (e) {
      debugPrint('Error adding interview history to Firestore: $e');
      throw DatabaseException('Failed to add interview history: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getInterviewHistory(String userId) async {
    if (_currentUserId == null || _currentUserId != userId) {
      debugPrint('Error: Unauthorized attempt to get interview history for $userId.');
      throw DatabaseException('Unauthorized: Cannot access history of another user.');
    }
    try {
      final querySnapshot = await _firestore.collection('artifacts').doc(_appId).collection('users').doc(userId).collection('interview_history').orderBy('timestamp', descending: true).get();
      // Note: orderBy might require an index in Firestore. If you encounter errors, remove orderBy.
      final List<Map<String, dynamic>> history = querySnapshot.docs.map((doc) => doc.data()).toList();
      debugPrint('Fetched ${history.length} interview history items from Firestore for UID: $userId');
      return history;
    } catch (e) {
      debugPrint('Error getting interview history from Firestore: $e');
      throw DatabaseException('Failed to retrieve interview history: $e');
    }
  }

  // New: Clears all interview history for a specific user.
  Future<void> clearAllInterviewHistory(String userId) async {
    if (_currentUserId == null || _currentUserId != userId) {
      debugPrint('Error: Unauthorized attempt to clear interview history for $userId.');
      throw DatabaseException('Unauthorized: Cannot clear history for another user.');
    }
    try {
      final collectionRef = _firestore.collection('artifacts').doc(_appId).collection('users').doc(userId).collection('interview_history');
      final querySnapshot = await collectionRef.get();
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      debugPrint('All interview history cleared from Firestore for UID: $userId');
    } catch (e) {
      debugPrint('Error clearing all interview history from Firestore: $e');
      throw DatabaseException('Failed to clear all interview history: $e');
    }
  }
}

// Custom exception class for database errors
// Moved outside FreeDatabaseService to be a top-level class
class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}
