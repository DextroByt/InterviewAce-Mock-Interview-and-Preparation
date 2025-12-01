// lib/screens/main_wrapper.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // FIXED: Added import for ImageFilter

import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_text_styles.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'home/home_screen.dart';
import 'history/history_screen.dart';
import 'interview/interview_setup_screen.dart';
import 'settings/settings_screen.dart';

class MainWrapper extends StatefulWidget {
  static const String routeName = '/main-wrapper';

  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_handlePageChange);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChange() {
    setState(() {
      _selectedIndex = _pageController.page?.round() ?? _selectedIndex;
    });
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAuthReady = authProvider.isAuthenticated;

    // Show a loading screen or redirect if not authenticated
    if (!isAuthReady) {
      // This case should be handled by app.dart, but as a safeguard.
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        // physics: const NeverScrollableScrollPhysics(), // Disable swiping
        children: const [
          HomeScreen(),
          HistoryScreen(),
          InterviewSetupScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.borderRadiusLarge)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: BottomNavigationBar(
            backgroundColor: AppColors.surfaceDark.withOpacity(0.2),
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: AppColors.primaryLight,
            unselectedItemColor: AppColors.textSecondaryDark.withOpacity(0.7),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedLabelStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
            unselectedLabelStyle: AppTextStyles.caption,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.history_outlined), label: 'History'),
              BottomNavigationBarItem(icon: Icon(Icons.mic_none), label: 'Interview'),
              BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
            ],
          ),
        ),
      ),
    );
  }
}
