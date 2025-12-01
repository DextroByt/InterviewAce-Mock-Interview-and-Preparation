// lib/app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // NEW: Import for SystemChrome

import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/profile_setup_screen.dart';
import 'screens/interview/interview_setup_screen.dart';
import 'screens/interview/interview_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/report/interview_report_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/prepare/prepare_screen.dart';
import 'screens/settings/privacy_policy_screen.dart';
import 'screens/settings/about_screen.dart';
import 'screens/settings/feedback_screen.dart'; // UPDATED: Import new feedback screen
import 'screens/settings/faq_screen.dart'; // NEW: Import new FAQ screen


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Lock the application to portrait orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Listen to ThemeProvider for theme changes
    final themeProvider = Provider.of<ThemeProvider>(context);
    // Listen to AuthProvider for authentication state changes
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      title: 'InterviewAce',
      // Apply the current theme (light or dark) from ThemeProvider
      theme: themeProvider.currentTheme,
      // Hide the debug banner in release mode
      debugShowCheckedModeBanner: false,

      // Define the named routes for navigation
      routes: {
        '/': (context) {
          // Determine the initial route based on authentication state
          // If authenticated, go to home_screen, otherwise login_screen
          if (authProvider.isAuthenticated) {
            // In a real app, you might check if profile setup is complete here
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
        LoginScreen.routeName: (context) => const LoginScreen(),
        SignUpScreen.routeName: (context) => const SignUpScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        ProfileSetupScreen.routeName: (context) => const ProfileSetupScreen(),
        InterviewSetupScreen.routeName: (context) => const InterviewSetupScreen(),
        InterviewScreen.routeName: (context) => const InterviewScreen(),
        HistoryScreen.routeName: (context) => const HistoryScreen(),
        InterviewReportScreen.routeName: (context) => const InterviewReportScreen(),
        SettingsScreen.routeName: (context) => const SettingsScreen(),
        PrepareScreen.routeName: (context) => const PrepareScreen(),
        PrivacyPolicyScreen.routeName: (context) => const PrivacyPolicyScreen(),
        AboutScreen.routeName: (context) => const AboutScreen(),
        FeedbackScreen.routeName: (context) => const FeedbackScreen(), // UPDATED: Register the new feedback screen
        FaqScreen.routeName: (context) => const FaqScreen(), // NEW: Register the new FAQ screen
      },

      // Use onGenerateRoute for more complex routing logic, especially for passing arguments
      onGenerateRoute: (settings) {
        // Example of passing arguments to InterviewReportScreen
        if (settings.name == InterviewReportScreen.routeName) {
          final args = settings.arguments;
          // You can pass arguments to the InterviewReportScreen if needed,
          // though currently it fetches from InterviewProvider.
          // If you want to pass a specific historical interview, you'd do it here.
          return MaterialPageRoute(builder: (context) => const InterviewReportScreen());
        }
        return null; // Let the default routes handle other cases
      },
    );
  }
}
