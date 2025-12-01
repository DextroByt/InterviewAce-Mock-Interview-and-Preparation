// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/storage_service.dart';
import 'core/constants/app_constants.dart';

import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/interview_provider.dart';
import 'providers/user_profile_provider.dart';

import 'services/free_ai_service.dart';
import 'services/free_speech_analyzer.dart';
import 'services/free_stt_service.dart';
import 'services/eleven_labs_tts_service.dart';
import 'services/free_report_service.dart';
import 'services/free_database_service.dart';
import 'firebase_options.dart';

// NEW: This package is added to pubspec.yaml for the new feedback functionality
import 'package:url_launcher/url_launcher.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully!');
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // FIX: Use the singleton instance of StorageService and initialize it.
  // This ensures it's ready before the app starts.
  final StorageService storageService = StorageService();
  await storageService.init();

  final AuthService authService = AuthService();
  final ApiService apiService = ApiService(
    baseUrl: AppConstants.geminiApiBaseUrl,
    apiKey: AppConstants.geminiApiKey,
  );
  final FreeAiService aiService = FreeAiService(apiService: apiService);
  final FreeSpeechToText sttService = FreeSpeechToText();
  await sttService.initSTT();
  final ElevenLabsTtsService ttsService = ElevenLabsTtsService();
  final FreeSpeechAnalyzer speechAnalyzer = FreeSpeechAnalyzer();
  final FreeReportService reportService = FreeReportService();
  final FreeDatabaseService databaseService = FreeDatabaseService();


  runApp(
    MultiProvider(
      providers: [
        // FIX: Provide the already initialized singleton instance.
        Provider<StorageService>.value(value: storageService),
        Provider<AuthService>.value(value: authService),
        Provider<ApiService>.value(value: apiService),
        Provider<FreeAiService>.value(value: aiService),
        Provider<FreeSpeechToText>.value(value: sttService),
        Provider<ElevenLabsTtsService>.value(value: ttsService),
        Provider<FreeSpeechAnalyzer>.value(value: speechAnalyzer),
        Provider<FreeReportService>.value(value: reportService),
        Provider<FreeDatabaseService>.value(value: databaseService),

        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProfileProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => InterviewProvider(),
        ),
      ],
      child: const App(),
    ),
  );
}
