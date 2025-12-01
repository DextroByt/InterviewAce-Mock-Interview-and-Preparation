// lib/core/services/storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:async'; // For Completer

// This service manages local data persistence using SharedPreferences.
// FIX: It now uses a singleton pattern to ensure it's initialized only once
// and is safe from race conditions.

class StorageService {
  // Singleton setup
  static final StorageService _instance = StorageService._internal();
  factory StorageService() {
    return _instance;
  }
  StorageService._internal();

  late SharedPreferences _prefs;
  final Completer<void> _initCompleter = Completer<void>();

  // Keys for SharedPreferences
  static const String _userProfileKey = 'user_profile';
  static const String _interviewHistoryKey = 'interview_history';
  static const String _themePreference = 'theme_preference';

  // Initializes SharedPreferences instance. This is now called automatically.
  Future<void> init() async {
    if (!_initCompleter.isCompleted) {
      try {
        _prefs = await SharedPreferences.getInstance();
        debugPrint('StorageService initialized successfully.');
        _initCompleter.complete();
      } catch (e) {
        debugPrint('Error initializing StorageService: $e');
        _initCompleter.completeError(e);
      }
    }
    return _initCompleter.future;
  }

  // Helper to ensure initialization is complete before any operation
  Future<void> _ensureInitialized() async {
    return _initCompleter.future;
  }

  // --- User Profile Management ---
  Future<void> saveUserProfile(Map<String, dynamic> profileData) async {
    await _ensureInitialized();
    try {
      final String jsonString = jsonEncode(profileData);
      await _prefs.setString(_userProfileKey, jsonString);
      debugPrint('User profile saved locally.');
    } catch (e) {
      debugPrint('Error saving user profile: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    await _ensureInitialized();
    try {
      final String? jsonString = _prefs.getString(_userProfileKey);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error retrieving user profile: $e');
    }
    return null;
  }

  Future<void> clearUserProfile() async {
    await _ensureInitialized();
    try {
      await _prefs.remove(_userProfileKey);
      debugPrint('User profile cleared locally.');
    } catch (e) {
      debugPrint('Error clearing user profile: $e');
    }
  }

  // --- Interview History Management ---
  Future<void> saveInterviewHistory(List<Map<String, dynamic>> historyList) async {
    await _ensureInitialized();
    try {
      final List<String> jsonList = historyList.map((item) => jsonEncode(item)).toList();
      await _prefs.setStringList(_interviewHistoryKey, jsonList);
      debugPrint('Interview history saved locally.');
    } catch (e) {
      debugPrint('Error saving interview history: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getInterviewHistory() async {
    await _ensureInitialized();
    try {
      final List<String>? jsonList = _prefs.getStringList(_interviewHistoryKey);
      if (jsonList != null) {
        return jsonList.map((jsonString) => jsonDecode(jsonString) as Map<String, dynamic>).toList();
      }
    } catch (e) {
      debugPrint('Error retrieving interview history: $e');
    }
    return [];
  }

  Future<void> clearInterviewHistory() async {
    await _ensureInitialized();
    try {
      await _prefs.remove(_interviewHistoryKey);
      debugPrint('Local interview history cleared.');
    } catch (e) {
      debugPrint('Error clearing local interview history: $e');
    }
  }

  // --- Theme Preference Management ---
  Future<void> saveThemePreference(String theme) async {
    await _ensureInitialized();
    try {
      await _prefs.setString(_themePreference, theme);
      debugPrint('Theme preference saved: $theme');
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  Future<String?> getThemePreference() async {
    await _ensureInitialized();
    try {
      return _prefs.getString(_themePreference);
    } catch (e) {
      debugPrint('Error retrieving theme preference: $e');
    }
    return null;
  }

  // --- General Data Clearing ---
  Future<void> clearAllStorage() async {
    await _ensureInitialized();
    try {
      await _prefs.clear();
      debugPrint('All local storage cleared.');
    } catch (e) {
      debugPrint('Error clearing all local storage: $e');
    }
  }
}
