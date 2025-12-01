// lib/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // For ImageFilter.blur
import 'dart:io';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/helpers.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_widget.dart';

import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../history/history_screen.dart';
import '../interview/interview_setup_screen.dart';
import '../onboarding/profile_setup_screen.dart';
import 'privacy_policy_screen.dart';
import 'about_screen.dart';
import 'feedback_screen.dart'; // UPDATED: Import the new feedback screen
import 'faq_screen.dart'; // NEW: Import the new FAQ screen

// This screen provides access to application settings and user profile management,
// adhering to the Glassmorphism theme. It now features a prominent profile section
// and a streamlined settings experience with new pages for key information.

class SettingsScreen extends StatefulWidget {
  static const String routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 3; // Set to 3 for Settings tab

  @override
  void initState() {
    super.initState();
    // Ensure user profile is fetched when entering settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProfileProvider>(context, listen: false).fetchUserProfile(context);
    });
  }

  // Handles navigation for the Bottom Navigation Bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Home
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        break;
      case 1: // History
        Navigator.of(context).pushReplacementNamed(HistoryScreen.routeName);
        break;
      case 2: // Interview
        Navigator.of(context).pushReplacementNamed(InterviewSetupScreen.routeName);
        break;
      case 3: // Settings (Current Screen)
      // Already on Settings, do nothing or refresh
        break;
    }
  }

  // Handles user logout
  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false);

    try {
      // Clear user profile data locally before logging out from Firebase
      await userProfileProvider.clearProfile();
      await authProvider.logout();
      Helpers.showSnackbar(context, 'Logged out successfully!', backgroundColor: AppColors.success);
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    } catch (e) {
      Helpers.showSnackbar(context, 'Logout failed: $e', backgroundColor: AppColors.error);
    }
  }

  // NEW: Handles the password reset functionality.
  Future<void> _handleResetPassword() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = authProvider.loggedInUser?.email;

    if (email == null) {
      Helpers.showSnackbar(context, 'No email found for this account. Please contact support.', backgroundColor: AppColors.error);
      return;
    }

    try {
      await authProvider.sendPasswordResetEmail(email);
      Helpers.showSnackbar(context, 'Password reset link has been sent to your email address.', backgroundColor: AppColors.success);
    } catch (e) {
      Helpers.showSnackbar(context, e.toString(), backgroundColor: AppColors.error);
    }
  }

  // NEW: Handles user account deletion
  Future<void> _handleDeleteAccount() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false);

    // Show a confirmation dialog before proceeding
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundDark.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            side: BorderSide(color: AppColors.primaryLight.withOpacity(0.2)),
          ),
          title: Text(
            'Delete Account?',
            style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimaryDark),
          ),
          content: Text(
            'Are you sure you want to permanently delete your account? This action cannot be undone.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: AppTextStyles.buttonText.copyWith(color: AppColors.textSecondaryDark),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            CustomButton(
              text: 'Delete',
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              isSecondary: true,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
                textStyle: AppTextStyles.buttonText.copyWith(fontSize: 14),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        // First, clear local and cloud data related to the user
        await userProfileProvider.clearProfile();
        // Then delete the user from Firebase Auth
        await authProvider.deleteAccount();

        if (mounted) {
          Helpers.showSnackbar(context, 'Account deleted successfully!', backgroundColor: AppColors.success);
          Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
        }
      } catch (e) {
        if (mounted) {
          Helpers.showSnackbar(context, 'Account deletion failed: $e', backgroundColor: AppColors.error);
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context); // Keep for potential future theme options

    // Display a loading indicator if user profile is still being fetched
    if (userProfileProvider.userProfile == null && authProvider.isAuthenticated) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: LoadingWidget(
          isFullScreen: true,
          message: 'Loading settings...',
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark, // Consistent dark background
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimaryDark),
        ),
        backgroundColor: AppColors.backgroundDark.withOpacity(0.5),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Advanced Background - Subtle Animated Gradient
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(seconds: 5), // Duration for background animation
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.backgroundDark,
                    AppColors.primaryDark.withOpacity(0.8), // Darker primary for subtle glow
                    AppColors.backgroundDark,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Profile Section ---
                _buildProfileCard(userProfileProvider),
                const SizedBox(height: AppConstants.paddingExtraLarge),

                // --- General Settings Section ---
                Text(
                  'General Settings',
                  style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimaryDark),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                AppTheme.applyGlassmorphism(
                  blurX: 10.0, blurY: 10.0, opacity: 0.15,
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Column(
                      children: [
                        _buildSettingsTile(
                          context,
                          title: 'Privacy Policy',
                          icon: Icons.privacy_tip_outlined,
                          onTap: () {
                            Navigator.of(context).pushNamed(PrivacyPolicyScreen.routeName);
                          },
                        ),
                        _buildSettingsDivider(),
                        _buildSettingsTile(
                          context,
                          title: 'About InterviewAce',
                          icon: Icons.info_outline,
                          onTap: () {
                            Navigator.of(context).pushNamed(AboutScreen.routeName);
                          },
                        ),
                        _buildSettingsDivider(),
                        _buildSettingsTile(
                          context,
                          title: 'Frequently Asked Questions',
                          icon: Icons.question_answer_outlined,
                          onTap: () {
                            Navigator.of(context).pushNamed(FaqScreen.routeName);
                          },
                        ),
                        _buildSettingsDivider(),
                        _buildSettingsTile(
                          context,
                          title: 'Feedback',
                          icon: Icons.rate_review_outlined,
                          onTap: () {
                            Navigator.of(context).pushNamed(FeedbackScreen.routeName);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingExtraLarge),

                // --- Account Actions ---
                Text(
                  'Account Actions',
                  style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimaryDark),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                AppTheme.applyGlassmorphism(
                  blurX: 10.0, blurY: 10.0, opacity: 0.15,
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Column(
                      children: [
                        _buildSettingsTile(
                          context,
                          title: 'Reset Password',
                          icon: Icons.lock_reset_outlined,
                          onTap: _handleResetPassword,
                        ),
                        _buildSettingsDivider(),
                        _buildSettingsTile(
                          context,
                          title: 'Delete Account',
                          icon: Icons.delete_forever_outlined,
                          onTap: _handleDeleteAccount,
                          iconColor: AppColors.error,
                          textColor: AppColors.error,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingExtraLarge),

                // --- Logout Button (Seperate Section) ---
                CustomButton(
                  text: 'LOG OUT',
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  isOutline: true,
                  isSecondary: true,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.error, // Red text for logout
                    side: const BorderSide(color: AppColors.error, width: 1),
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
                    textStyle: AppTextStyles.buttonText.copyWith(fontSize: 14),
                    minimumSize: Size.zero,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingExtraLarge + 80), // Space for bottom nav bar
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.borderRadiusLarge)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: BottomNavigationBar(
            backgroundColor: AppColors.backgroundDark.withOpacity(0.5), // Transparent background
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: AppColors.primaryLight, // White for selected
            unselectedItemColor: AppColors.textSecondaryDark.withOpacity(0.6), // Grey for unselected
            type: BottomNavigationBarType.fixed, // Ensures all labels are shown
            selectedLabelStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
            unselectedLabelStyle: AppTextStyles.caption,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.mic), // Microphone for Start Interview
                label: 'Interview',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build the Profile Card
  Widget _buildProfileCard(UserProfileProvider userProfileProvider) {
    // Determine the profile picture URL to display
    final String? profilePicturePath = userProfileProvider.userProfile?.profilePicturePath;
    final bool hasProfilePicture = profilePicturePath != null && File(profilePicturePath).existsSync();

    ImageProvider? backgroundImage;
    if (hasProfilePicture) {
      backgroundImage = FileImage(File(profilePicturePath));
    } else {
      backgroundImage = null; // Use placeholder icon
    }

    return AppTheme.applyGlassmorphism(
      blurX: 10.0, blurY: 10.0, opacity: 0.15,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          children: [
            CircleAvatar(
              key: ValueKey(profilePicturePath), // Add this key to force rebuild on path change
              radius: 50,
              backgroundColor: AppColors.surfaceDark.withOpacity(0.5),
              backgroundImage: backgroundImage,
              child: (_selectedIndex == 3 && !hasProfilePicture) // only show icon on settings screen
                  ? Icon(Icons.person, size: 50, color: AppColors.textSecondaryDark)
                  : null,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              userProfileProvider.userProfile?.displayName ?? 'Guest User',
              style: AppTextStyles.heading2.copyWith(color: AppColors.primaryLight),
              textAlign: TextAlign.center,
            ),
            Text(
              userProfileProvider.userProfile?.email ?? 'N/A',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            CustomButton(
              text: 'EDIT PROFILE',
              onPressed: () {
                Navigator.of(context).pushNamed(ProfileSetupScreen.routeName);
              },
              isOutline: true,
              isSecondary: true,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                textStyle: AppTextStyles.buttonText.copyWith(fontSize: 12),
                minimumSize: Size.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build a single settings tile
  Widget _buildSettingsTile(BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
    Color? iconColor,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall, horizontal: AppConstants.paddingSmall),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppColors.textPrimaryDark, size: AppConstants.iconSizeMedium),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(color: textColor ?? AppColors.textPrimaryDark),
              ),
            ),
            if (trailing != null) trailing,
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondaryDark.withOpacity(0.6),
              size: AppConstants.iconSizeSmall,
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for a divider in settings list
  Widget _buildSettingsDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingSmall),
      child: Divider(
        color: AppColors.textSecondaryDark.withOpacity(0.2),
        thickness: 1,
      ),
    );
  }
}
