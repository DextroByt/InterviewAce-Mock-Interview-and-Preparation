// lib/screens/settings/about_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  static const String routeName = '/about';

  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          'About InterviewAce',
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
                    _buildSectionHeader(context, 'Our Mission'),
                    _buildSectionContent(
                      context,
                      'InterviewAce is a cutting-edge, AI-powered platform designed to revolutionize how you prepare for job interviews. Our mission is to provide personalized, insightful, and effective practice sessions that build your confidence and sharpen your skills, helping you land your dream job.',
                    ),
                    _buildSectionHeader(context, 'What We Offer'),
                    _buildSectionContent(
                      context,
                      'Here\'s what makes InterviewAce your ultimate interview companion:',
                      isBold: true,
                    ),
                    _buildListItem(context, Icons.mic, 'AI-powered mock interviews tailored to your career goals.'),
                    _buildListItem(context, Icons.analytics_outlined, 'Detailed performance reports with actionable feedback.'),
                    _buildListItem(context, Icons.lightbulb_outline, 'A comprehensive learning hub with quizzes and solutions.'),
                    _buildListItem(context, Icons.design_services_outlined, 'A sleek, modern user interface with a focus on user experience.'),

                    _buildSectionHeader(context, 'Technology Stack'),
                    _buildSectionContent(
                      context,
                      'Built with Flutter, Firebase, and integrating advanced AI models like Google Gemini and ElevenLabs TTS, InterviewAce is a testament to modern mobile development and artificial intelligence.',
                    ),
                    _buildSectionHeader(context, 'Developers'),
                    _buildDeveloperCard(context, 'Akash Chakresh', 'Senior Developer', '12.AkashChakresh@gmail.com', '+91 8692914734'),
                    const SizedBox(height: AppConstants.paddingMedium),
                    _buildDeveloperCard(context, 'Roshan Chaudhary', 'Junior Developer', '13.RoshanChaudhary@gmail.com', '+91 9284028853'),

                    const SizedBox(height: AppConstants.paddingExtraLarge),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        '© 2024 InterviewAce. All rights reserved.',
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

  Widget _buildListItem(BuildContext context, IconData icon, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppConstants.iconSizeSmall, color: AppColors.primaryLight),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Text(
              content,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
            ),
          ),
        ],
      ),
    );
  }

  // Updated developer card to include contact info
  Widget _buildDeveloperCard(BuildContext context, String name, String role, String email, String phone) {
    return AppTheme.applyGlassmorphism(
      blurX: 5.0,
      blurY: 5.0,
      opacity: 0.1,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.person, color: AppColors.backgroundDark),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    role,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.info_outline, color: AppColors.primaryLight),
              onPressed: () => _showDeveloperInfoDialog(context, name, email, phone),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeveloperInfoDialog(BuildContext context, String name, String email, String phone) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundDark.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            side: BorderSide(color: AppColors.primaryLight.withOpacity(0.2)),
          ),
          title: Text(
            'Contact $name',
            style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimaryDark),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: $email', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark)),
              const SizedBox(height: AppConstants.paddingSmall),
              Text('Phone: $phone', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark)),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Close',
                style: AppTextStyles.buttonText.copyWith(color: AppColors.textSecondaryDark),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
