// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle
import 'dart:ui'; // For ImageFilter.blur

import '../constants/app_colors.dart'; // Corrected path
import '../constants/app_text_styles.dart'; // Corrected path
import '../constants/app_constants.dart'; // Corrected path

// This file configures the complete ThemeData for the application,
// including color schemes, typography, button themes, and other visual properties.
// It specifically implements the glassmorphism effects for the dark theme.

class AppTheme {
  // --- Light Theme ---
  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: AppColors.lightColorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark, // Dark icons on light app bar
        titleTextStyle: AppTextStyles.heading2.copyWith(color: AppColors.textPrimaryLight),
      ),
      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.heading1.copyWith(color: AppColors.textPrimaryLight),
        displayMedium: AppTextStyles.heading2.copyWith(color: AppColors.textPrimaryLight),
        displaySmall: AppTextStyles.heading3.copyWith(color: AppColors.textPrimaryLight),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryLight),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryLight),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
        labelLarge: AppTextStyles.buttonText.copyWith(color: Colors.white), // For buttons
        labelSmall: AppTextStyles.caption.copyWith(color: AppColors.textSecondaryLight),
      ),
      // Card Theme
      cardTheme: CardThemeData( // Changed to CardThemeData
        color: AppColors.surfaceLight,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
        margin: EdgeInsets.zero, // Cards will define their own margins
      ),
      // Input Decoration Theme (for text fields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingSmall),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none, // No border by default
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppColors.textSecondaryLight.withOpacity(0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryLight),
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
      ),
      // ElevatedButton Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
              vertical: AppConstants.paddingMedium),
          textStyle: AppTextStyles.buttonText,
          elevation: 3,
        ),
      ),
      // TextButton Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.buttonText.copyWith(fontWeight: FontWeight.normal),
        ),
      ),
      // OutlinedButton Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
              vertical: AppConstants.paddingMedium),
          textStyle: AppTextStyles.buttonText,
        ),
      ),
      // FloatingActionButton Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
      ),
      // Dialog Theme
      dialogTheme: DialogThemeData( // Changed to DialogThemeData
        backgroundColor: AppColors.backgroundLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
        titleTextStyle: AppTextStyles.heading3.copyWith(color: AppColors.textPrimaryLight),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryLight),
      ),
    );
  }

  // --- Dark Theme with Glassmorphism ---
  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: AppColors.darkColorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark, // Deep rich black background

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light, // Light icons on dark app bar
        titleTextStyle: AppTextStyles.heading2.copyWith(color: AppColors.textPrimaryDark),
      ),
      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.heading1.copyWith(color: AppColors.textPrimaryDark),
        displayMedium: AppTextStyles.heading2.copyWith(color: AppColors.textPrimaryDark),
        displaySmall: AppTextStyles.heading3.copyWith(color: AppColors.textPrimaryDark),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryDark),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryDark),
        labelLarge: AppTextStyles.buttonText.copyWith(color: Colors.black), // For buttons
        labelSmall: AppTextStyles.caption.copyWith(color: AppColors.textSecondaryDark),
      ),
      // Card Theme (Glassmorphism Effect)
      cardTheme: CardThemeData( // Changed to CardThemeData
        color: AppColors.surfaceDark.withOpacity(0.2), // Subtle transparency
        elevation: 0, // No direct shadow, rely on BackdropFilter for depth
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          side: BorderSide(
            color: AppColors.textPrimaryDark.withOpacity(0.1), // Subtle border
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      // Input Decoration Theme (Glassmorphism Effect)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark.withOpacity(0.2), // Subtle transparency
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingSmall),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppColors.textSecondaryDark.withOpacity(0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
      ),
      // ElevatedButton Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight, // Lighter primary for dark theme
          foregroundColor: AppColors.backgroundDark, // Dark text on light button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
              vertical: AppConstants.paddingMedium),
          textStyle: AppTextStyles.buttonText,
          elevation: 3,
        ),
      ),
      // TextButton Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          textStyle: AppTextStyles.buttonText.copyWith(fontWeight: FontWeight.normal),
        ),
      ),
      // OutlinedButton Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.primaryLight, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
              vertical: AppConstants.paddingMedium),
          textStyle: AppTextStyles.buttonText,
        ),
      ),
      // FloatingActionButton Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondaryLight,
        foregroundColor: AppColors.backgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
      ),
      // Dialog Theme (Glassmorphism Effect)
      dialogTheme: DialogThemeData( // Changed to DialogThemeData
        backgroundColor: AppColors.surfaceDark.withOpacity(0.2), // Subtle transparency
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          side: BorderSide(
            color: AppColors.textPrimaryDark.withOpacity(0.1), // Subtle border
            width: 1,
          ),
        ),
        titleTextStyle: AppTextStyles.heading3.copyWith(color: AppColors.textPrimaryDark),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
      ),
    );
  }

  // Helper method to apply BackdropFilter for Glassmorphism.
  // This will be used in custom widgets that need the blur effect.
  static Widget applyGlassmorphism(
      {required Widget child,
        double blurX = 10.0,
        double blurY = 10.0,
        double opacity = 0.2,
        Color? overlayColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurX, sigmaY: blurY),
        child: Container(
          decoration: BoxDecoration(
            color: (overlayColor ?? AppColors.surfaceDark).withOpacity(opacity),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            border: Border.all(
              color: AppColors.textPrimaryDark.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

