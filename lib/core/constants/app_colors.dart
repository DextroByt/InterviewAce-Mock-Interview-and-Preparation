// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

// This file defines the color palette for the InterviewAce application.
// It is now primarily black and white, retaining status colors.

class AppColors {
  // --- Primary Colors (Black/White Focused) ---
  static const Color primary = Color(0xFF000000); // Main Black
  static const Color primaryDark = Color(0xFF1A1A1A); // Slightly darker black for depth
  static const Color primaryLight = Color(0xFFFFFFFF); // Main White

  // --- Secondary Colors (Black/White Focused) ---
  static const Color secondary = Color(0xFF333333); // Dark Gray for secondary actions in light mode
  static const Color secondaryDark = Color(0xFF222222); // Even darker gray
  static const Color secondaryLight = Color(0xFFE0E0E0); // Light Gray for secondary actions in dark mode

  // --- Neutral Colors ---
  // Background colors
  static const Color backgroundLight = Color(0xFFFFFFFF); // Pure White background
  static const Color backgroundDark = Color(0xFF000000); // Pure Black background for glassmorphism

  // Surface colors (used for cards, dialogs, input fields - will be transparent in dark theme)
  static const Color surfaceLight = Color(0xFFF0F0F0); // Very light gray for surfaces in light mode
  static const Color surfaceDark = Color(0xFF1A1A1A); // Dark gray for dark theme surfaces (will be transparent)

  // Text colors
  static const Color textPrimaryLight = Color(0xFF000000); // Black text on light background
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // White text on dark background
  static const Color textSecondaryLight = Color(0xFF666666); // Medium gray for secondary text in light mode
  static const Color textSecondaryDark = Color(0xFFCCCCCC); // Light gray for secondary text in dark mode

  // --- Status Colors (Retained as is) ---
  static const Color success = Color(0xFF10B981); // Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Blue

  // --- ColorScheme Definitions ---
  // These ColorScheme objects are used by ThemeData to define the overall theme.
  // They are based on the defined static colors above.

  static ColorScheme lightColorScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: primary, // Black
    onPrimary: Colors.white, // White text on black primary
    secondary: secondary, // Dark Gray
    onSecondary: Colors.white, // White text on dark gray secondary
    error: error,
    onError: Colors.white,
    background: backgroundLight, // White
    onBackground: textPrimaryLight, // Black text on white background
    surface: surfaceLight, // Very light gray
    onSurface: textPrimaryLight, // Black text on light gray surface
  );

  static ColorScheme darkColorScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: primaryLight, // White (for contrast on black background)
    onPrimary: Colors.black, // Black text on white primary
    secondary: secondaryLight, // Light Gray (for contrast on black background)
    onSecondary: Colors.black, // Black text on light gray secondary
    error: error,
    onError: Colors.white,
    background: backgroundDark, // Black
    onBackground: textPrimaryDark, // White text on black background
    surface: surfaceDark, // Dark gray (will be visually transparent via BackdropFilter)
    onSurface: textPrimaryDark, // White text on dark gray surface
  );
}

