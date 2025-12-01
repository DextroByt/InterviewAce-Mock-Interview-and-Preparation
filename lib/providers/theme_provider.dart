// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:shared_preferences/shared_preferences.dart'; // Still needed for init but not for theme preference

import '../core/theme/app_theme.dart'; // Corrected path
import '../core/services/storage_service.dart'; // Corrected path

// This provider now permanently manages the application's theme to be dark mode.
// Theme switching functionality has been removed.

class ThemeProvider with ChangeNotifier {
  ThemeData _currentTheme;
  final StorageService _storageService;

  // Key for theme preference storage (no longer used for toggling, but kept for consistency if other prefs exist)
  static const String _themeKey = 'theme_preference';

  ThemeProvider(SharedPreferences prefs)
      : _storageService = StorageService(),
        _currentTheme = AppTheme.darkTheme() { // Always default to dark theme
    _storageService.init().then((_) {
      // We no longer load a preference, as the theme is fixed to dark.
      // We could optionally save 'dark' once to ensure consistency if needed.
      // _storageService.saveThemePreference('dark'); // Optional: ensure 'dark' is saved
      debugPrint('Theme provider initialized. App is permanently in dark mode.');
    });
  }

  ThemeData get currentTheme => _currentTheme;

  // Removed _loadThemePreference as theme is now fixed.
  // Removed toggleTheme as theme is now fixed.

  // Sets a specific theme (now only allows setting to dark, or is effectively a no-op for light)
  Future<void> setTheme(Brightness brightness) async {
    // This method now ensures the theme is dark.
    // If you call setTheme(Brightness.light), it will still set dark.
    if (_currentTheme.brightness != Brightness.dark) {
      _currentTheme = AppTheme.darkTheme();
      // await _storageService.saveThemePreference('dark'); // Optional: ensure 'dark' is saved
      debugPrint('Attempted to set theme. App is permanently dark.');
      notifyListeners();
    }
  }
}
