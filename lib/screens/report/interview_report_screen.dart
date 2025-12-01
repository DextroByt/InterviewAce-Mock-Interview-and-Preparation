// lib/screens/report/interview_report_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // For ImageFilter.blur

import '../../core/constants/app_colors.dart'; // Corrected path
import '../../core/constants/app_constants.dart'; // Corrected path
import '../../core/constants/app_text_styles.dart'; // Corrected path
import '../../core/utils/helpers.dart'; // Corrected path
import '../../core/theme/app_theme.dart'; // For glassmorphism effect
import '../../providers/interview_provider.dart'; // Corrected path
import '../../widgets/common/custom_button.dart'; // Corrected path

import '../home/home_screen.dart'; // For navigation
import '../history/history_screen.dart'; // Corrected import path and class name
import '../interview/interview_setup_screen.dart'; // For navigation
import '../settings/settings_screen.dart'; // For navigation

// This screen displays the detailed performance report of a completed interview.
// It presents the overall analysis and provides options for further actions,
// adhering to the Glassmorphism theme. It now includes a breakdown of
// each question with user answers and individual analysis in an expandable format.

class InterviewReportScreen extends StatefulWidget {
  static const String routeName = '/interview-report';

  const InterviewReportScreen({super.key});

  @override
  State<InterviewReportScreen> createState() => _InterviewReportScreenState();
}

class _InterviewReportScreenState extends State<InterviewReportScreen> {
  int _selectedIndex = -1; // No specific tab selected for report screen

  @override
  void initState() {
    super.initState();
    // No specific action needed here, as data is provided via provider
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
      case 3: // Settings
        Navigator.of(context).pushReplacementNamed(SettingsScreen.routeName);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final interviewProvider = Provider.of<InterviewProvider>(context);
    final interview = interviewProvider.currentInterview;
    final analysis = interview?.analysis;

    // Handle cases where no interview or analysis is available
    if (interview == null || analysis == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          title: Text(
            'Interview Report',
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
            // Animated Background
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
            Center(
              child: AppTheme.applyGlassmorphism(
                blurX: 15.0, blurY: 15.0, opacity: 0.1,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'No interview report available.',
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryDark),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      CustomButton(
                        text: 'Start New Interview',
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed(InterviewSetupScreen.routeName);
                        },
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      CustomButton(
                        text: 'Go to Home',
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
                        },
                        isOutline: true,
                        isSecondary: true,
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

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          'Interview Report',
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
          // Animated Background
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Your Performance Summary',
                  style: AppTextStyles.heading1.copyWith(color: AppColors.textPrimaryDark),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.paddingExtraLarge),

                // --- Overall Feedback Card (Glassmorphism) ---
                AppTheme.applyGlassmorphism(
                  blurX: 10.0, blurY: 10.0, opacity: 0.15,
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall Feedback',
                          style: AppTextStyles.heading3.copyWith(color: AppColors.primaryLight),
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Text(
                          analysis.overallFeedback,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),

                // --- Key Metrics Card (Glassmorphism) ---
                AppTheme.applyGlassmorphism(
                  blurX: 10.0, blurY: 10.0, opacity: 0.15,
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Key Metrics',
                          style: AppTextStyles.heading3.copyWith(color: AppColors.primaryLight),
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        _buildMetricRow(
                          context,
                          'Speaking Rate:',
                          '${analysis.overallSpeakingRateWPM.toStringAsFixed(1)} WPM',
                        ),
                        _buildMetricRow(
                          context,
                          'Filler Words:',
                          '${analysis.totalFillerWordCount} words',
                        ),
                        _buildMetricRow(
                          context,
                          'Average Clarity:',
                          '${(analysis.averageClarityScore * 100).toStringAsFixed(0)}%',
                        ),
                        _buildMetricRow(
                          context,
                          'Dominant Emotions:',
                          analysis.dominantEmotions.entries
                              .map((e) => '${e.key} (${(e.value * 100).toStringAsFixed(0)}%)')
                              .join(', '),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),

                // --- Suggestions for Improvement Card (Glassmorphism) ---
                AppTheme.applyGlassmorphism(
                  blurX: 10.0, blurY: 10.0, opacity: 0.15,
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Suggestions for Improvement',
                          style: AppTextStyles.heading3.copyWith(color: AppColors.primaryLight),
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        if (analysis.suggestionsForImprovement.isEmpty)
                          Text(
                            'No specific suggestions at this time. Keep up the great work!',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: analysis.suggestionsForImprovement
                                .map((suggestion) => Padding(
                              padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall / 2),
                              child: Text(
                                '• $suggestion',
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
                              ),
                            ))
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingExtraLarge),

                // --- Detailed Question Breakdown Section (Expandable Tiles) ---
                Text(
                  'Detailed Question Breakdown',
                  style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimaryDark),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                Column(
                  children: List.generate(interview.questionsAndAnswers.length, (index) {
                    final qa = interview.questionsAndAnswers[index];
                    final qaAnalysis = qa.analysis;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                      child: AppTheme.applyGlassmorphism(
                        blurX: 8.0, blurY: 8.0, opacity: 0.1,
                        child: Theme(
                          // Override default ExpansionTile theme for custom appearance
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: AppConstants.paddingSmall),
                            collapsedIconColor: AppColors.textSecondaryDark,
                            iconColor: AppColors.primaryLight,
                            title: Text(
                              'Question ${index + 1}: ${qa.questionText}',
                              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            childrenPadding: const EdgeInsets.all(AppConstants.paddingLarge),
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your Answer:',
                                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.secondaryLight, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: AppConstants.paddingSmall),
                                  Text(
                                    qa.userResponse.isEmpty ? 'No response recorded.' : qa.userResponse,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: qa.userResponse.isEmpty ? AppColors.textSecondaryDark : AppColors.textPrimaryDark,
                                      fontStyle: qa.userResponse.isEmpty ? FontStyle.italic : FontStyle.normal,
                                    ),
                                  ),
                                  if (qaAnalysis != null) ...[
                                    const SizedBox(height: AppConstants.paddingLarge),
                                    Text(
                                      'Answer Analysis:',
                                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryLight, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: AppConstants.paddingSmall),
                                    _buildMetricRow(
                                      context,
                                      'Speech Rate:',
                                      '${qaAnalysis.speakingRateWPM.toStringAsFixed(1)} WPM',
                                    ),
                                    _buildMetricRow(
                                      context,
                                      'Filler Words:',
                                      '${qaAnalysis.fillerWordCount} words',
                                    ),
                                    _buildMetricRow(
                                      context,
                                      'Clarity Score:',
                                      '${(qaAnalysis.clarityScore * 100).toStringAsFixed(0)}%',
                                    ),
                                    // Removed 'Emotions' from individual question analysis display
                                    const SizedBox(height: AppConstants.paddingMedium),
                                    Text(
                                      'Feedback:',
                                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: AppConstants.paddingSmall / 2),
                                    Text(
                                      qaAnalysis.feedback,
                                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
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
            currentIndex: _selectedIndex == -1 ? 0 : _selectedIndex, // Default to home if no specific tab
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

  // Helper widget to build a row for a metric
  Widget _buildMetricRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Fixed width for labels for alignment
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
