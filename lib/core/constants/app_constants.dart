// lib/core/constants/app_constants.dart

// This file defines various app-wide constants and configuration values.

class AppConstants {
  // --- Gemini API ---
  static const String geminiApiBaseUrl = '';
  static const String geminiApiKey = ''; // Leave this empty. Canvas will inject it at runtime.
  static const String geminiModel = 'gemini-2.0-flash'; 
  // --- ElevenLabs TTS API ---
  // IMPORTANT: Replace with your actual ElevenLabs API key.
  static const String elevenLabsApiKey = "";

  // Voice IDs for the interviewers.
  // You can find more voices on the ElevenLabs website.
  // Example Voice IDs:
  // Male: Adam (pNInz6obpgDQGcFmaJgB)
  // Female: Rachel (21m00Tcm4TlvDq8ikWAM)
  static const String elevenLabsMaleVoiceId = "Zp1aWhL05Pi5BkhizFC3";
  static const String elevenLabsFemaleVoiceId = "fG9s0SXJb213f4UxVHyG";

  // NEW: Admin email for feedback.
  static const String adminEmail = '';


  // --- Animation Durations ---
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationNormal = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);

  // --- App Dimensions (Spacing, Padding, Sizing) ---
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;

  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  static const double iconSizeSmall = 18.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  // --- Other Constants ---
  static const int minPasswordLength = 8;
  static const int maxCareerGoals = 5;
  static const String defaultProfilePictureUrl =
      'https://placehold.co/150x150/6366F1/FFFFFF?text=IA';
}
