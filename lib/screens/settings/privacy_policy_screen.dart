// lib/screens/settings/privacy_policy_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  static const String routeName = '/privacy-policy';

  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
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
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(seconds: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.backgroundDark,
                    AppColors.primaryDark.withOpacity(0.8),
                    AppColors.backgroundDark,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: AppTheme.applyGlassmorphism(
              blurX: 10.0, blurY: 10.0, opacity: 0.15,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(context, '1. Introduction'),
                    _buildSectionContent(
                      context,
                      'Your privacy is a top priority for us. This Privacy Policy is designed to clearly inform you about how InterviewAce collects, uses, and protects your personal information. By using our application, you agree to the terms outlined in this policy.',
                    ),
                    _buildSectionHeader(context, '2. Information We Collect'),
                    _buildSectionContent(
                      context,
                      'We collect data to provide and improve our services, including:',
                      isBold: true,
                    ),
                    _buildListItem(context, 'Account Information:', 'This includes your name and email address, which you provide during sign-up.'),
                    _buildListItem(context, 'Interview Data:', 'Transcripts and performance metrics from your mock interviews are collected to generate personalized feedback and reports.'),
                    _buildListItem(context, 'Usage Data:', 'We collect data on how you interact with the app, such as pages visited and features used, to enhance your experience.'),

                    _buildSectionHeader(context, '3. How We Use Your Information'),
                    _buildSectionContent(
                      context,
                      'The information we collect is used to:',
                      isBold: true,
                    ),
                    _buildListItem(context, 'Personalize Your Experience:', 'To tailor mock interviews and learning content to your specific career goals and preferences.'),
                    _buildListItem(context, 'Provide Detailed Feedback:', 'To analyze your interview performance and generate insightful, actionable reports.'),
                    _buildListItem(context, 'Improve Our Services:', 'To understand user behavior and make continuous improvements to the app\'s functionality and features.'),

                    _buildSectionHeader(context, '4. Data Security'),
                    _buildSectionContent(
                      context,
                      'We are committed to protecting your data. We implement industry-standard security measures, including encryption and secure storage solutions, to safeguard your information from unauthorized access, alteration, or deletion.',
                    ),

                    _buildSectionHeader(context, '5. Your Rights & Control'),
                    _buildSectionContent(
                      context,
                      'You have full control over your data. You can:',
                      isBold: true,
                    ),
                    _buildListItem(context, 'Access and Modify:', 'Update your personal details and career goals at any time through the Profile Settings.'),
                    _buildListItem(context, 'Data Deletion:', 'Permanently delete your account and all associated data via the Settings screen. This action is irreversible.'),

                    const SizedBox(height: AppConstants.paddingExtraLarge),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'This policy is subject to change. We recommend reviewing it periodically.',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryDark.withOpacity(0.7)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.paddingLarge, bottom: AppConstants.paddingSmall / 2),
      child: Text(
        title,
        style: AppTextStyles.heading3.copyWith(color: AppColors.primaryLight),
      ),
    );
  }

  Widget _buildSectionContent(BuildContext context, String text, {bool isBold = false}) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondaryDark,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildListItem(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, size: AppConstants.iconSizeSmall, color: AppColors.success),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: title,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' $content',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
