// lib/core/constants/app_text_styles.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import for Google Fonts

// This file defines the typography system for the InterviewAce application.
// It uses the 'Inter' font family as specified in the design system.

class AppTextStyles {
  // Define the base font family. The document specifies 'Inter'.
  // Ensure you add google_fonts dependency to your pubspec.yaml:
  // google_fonts: ^6.1.0 (or latest version)
  static final String _fontFamily = GoogleFonts.inter().fontFamily!;

  // --- Heading Styles ---
  static TextStyle heading1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static TextStyle heading2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600, // SemiBold
    letterSpacing: -0.25,
  );

  static TextStyle heading3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600, // SemiBold
    letterSpacing: 0,
  );

  // --- Body Styles ---
  static TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal, // Regular
    letterSpacing: 0,
  );

  static TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal, // Regular
    letterSpacing: 0,
  );

  static TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal, // Regular
    letterSpacing: 0.25,
  );

  // --- Button Text Style ---
  static TextStyle buttonText = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600, // SemiBold
    letterSpacing: 0.5,
  );

  // --- Caption Style ---
  static TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500, // Medium
    letterSpacing: 0.5,
  );
}

