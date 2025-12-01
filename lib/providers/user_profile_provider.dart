// lib/providers/user_profile_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io'; // For File class
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../models/user_model.dart';
import '../core/services/storage_service.dart';
import '../services/free_database_service.dart';
import '../core/utils/helpers.dart';
import '../core/constants/app_colors.dart';

class UserProfileProvider with ChangeNotifier {
  UserModel? _userProfile;
  final StorageService _storageService = StorageService();
  final FreeDatabaseService _databaseService;

  UserModel? get userProfile => _userProfile;

  UserProfileProvider()
      : _databaseService = FreeDatabaseService() {
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final userProfileJson = await _storageService.getUserProfile();
    if (userProfileJson != null) {
      try {
        _userProfile = UserModel.fromJson(userProfileJson);
        debugPrint('User profile loaded from local storage.');
      } catch (e) {
        debugPrint('Error loading user profile from storage: $e');
        _userProfile = null;
      }
    }
    notifyListeners();
  }

  Future<void> fetchUserProfile(BuildContext context) async {
    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      debugPrint('No authenticated user to fetch profile for.');
      _userProfile = null;
      notifyListeners();
      return;
    }

    try {
      final Map<String, dynamic>? data = await _databaseService.getUserProfile(firebaseUser.uid);
      if (data != null) {
        _userProfile = UserModel.fromJson(data);
        await _storageService.saveUserProfile(data);
        debugPrint('User profile fetched from Firestore and updated locally.');
      } else {
        debugPrint('User profile not found in Firestore for UID: ${firebaseUser.uid}. Creating basic model.');
        _userProfile = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User',
          createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
          lastLoginAt: firebaseUser.metadata.lastSignInTime,
        );
        await _storageService.saveUserProfile(_userProfile!.toJson());
        await _databaseService.saveUserProfile(firebaseUser.uid, _userProfile!.toJson());
      }
    } on DatabaseException catch (e) {
      debugPrint('Database error fetching user profile: ${e.message}');
      if (_userProfile == null) {
        Helpers.showSnackbar(context, 'Failed to load profile from cloud: ${e.message}', backgroundColor: AppColors.error);
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      if (_userProfile == null) {
        Helpers.showSnackbar(context, 'An unexpected error occurred while fetching profile.', backgroundColor: AppColors.error);
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required BuildContext context,
    String? displayName,
    File? profilePictureFile, // New parameter for a local image file
    List<String>? careerGoals,
  }) async {
    if (_userProfile == null) {
      debugPrint('Cannot update profile: No user profile loaded.');
      return;
    }
    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      debugPrint('Cannot update profile: User not authenticated.');
      Helpers.showSnackbar(context, 'Authentication required to update profile.', backgroundColor: AppColors.error);
      return;
    }

    String? newProfilePicturePath = _userProfile!.profilePicturePath;
    // If a new image file is provided, save it to local storage
    if (profilePictureFile != null) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final String localPath = p.join(directory.path, 'profile_picture_${firebaseUser.uid}.png');
        await profilePictureFile.copy(localPath);
        newProfilePicturePath = localPath;
        debugPrint('New profile picture saved to local path: $newProfilePicturePath');
      } catch (e) {
        debugPrint('Error saving profile picture locally: $e');
        Helpers.showSnackbar(context, 'Failed to save new profile picture.', backgroundColor: AppColors.error);
        return;
      }
    }

    final updatedProfile = _userProfile!.copyWith(
      displayName: displayName,
      profilePicturePath: newProfilePicturePath,
      careerGoals: careerGoals,
    );

    try {
      await _databaseService.saveUserProfile(firebaseUser.uid, updatedProfile.toJson());
      await _storageService.saveUserProfile(updatedProfile.toJson());
      _userProfile = updatedProfile;
      debugPrint('User profile updated in Firestore and locally.');
    } on DatabaseException catch (e) {
      debugPrint('Database error updating user profile: ${e.message}');
      Helpers.showSnackbar(context, 'Failed to save profile to cloud: ${e.message}', backgroundColor: AppColors.error);
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      Helpers.showSnackbar(context, 'An unexpected error occurred while updating profile.', backgroundColor: AppColors.error);
    } finally {
      notifyListeners();
    }
  }

  // Method to update only the quiz progress badge in the user profile.
  Future<void> updateQuizProgress(String badge) async {
    if (_userProfile == null) {
      debugPrint('Cannot update quiz progress: No user profile loaded.');
      return;
    }

    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      debugPrint('Cannot update quiz progress: User not authenticated.');
      return;
    }

    final updatedProfile = _userProfile!.copyWith(
      quizBadge: badge,
    );

    try {
      await _storageService.saveUserProfile(updatedProfile.toJson());
      _userProfile = updatedProfile;
      debugPrint('Quiz progress updated locally.');

      await _databaseService.saveUserProfile(firebaseUser.uid, {'quizBadge': badge});
      debugPrint('Quiz progress updated in Firestore.');
    } on DatabaseException catch (e) {
      debugPrint('Database error updating quiz progress: ${e.message}');
    } catch (e) {
      debugPrint('Error updating quiz progress: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> clearProfile() async {
    _userProfile = null;
    await _storageService.clearUserProfile();
    debugPrint('User profile cleared from state and local storage.');
    notifyListeners();
  }
}
