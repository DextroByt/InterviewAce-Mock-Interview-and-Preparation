// lib/screens/learn/quiz_results_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_widget.dart';

import '../home/home_screen.dart';

class QuizResultsScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final String jobRole;

  const QuizResultsScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.jobRole,
  });

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen> {
  String _quizBadge = 'None';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateAndSaveProgress();
    });
  }

  void _calculateAndSaveProgress() {
    final percentage = (widget.score / widget.totalQuestions) * 100;
    String newBadge;

    if (percentage >= 80) { // UPDATED: Lowered threshold to 80% for Gold
      newBadge = 'Gold';
    } else if (percentage >= 60) { // UPDATED: Lowered threshold to 60% for Silver
      newBadge = 'Silver';
    } else if (percentage >= 30) { // UPDATED: Lowered threshold to 30% for Bronze
      newBadge = 'Bronze';
    } else {
      newBadge = 'None';
    }

    // Set the badge to display on the screen to the result of the current quiz.
    setState(() {
      _quizBadge = newBadge;
    });

    // Check if the new badge is a higher rank than the current highest badge.
    final userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    final currentBadge = userProfileProvider.userProfile?.quizBadge ?? 'None';
    final currentRank = _getBadgeRank(currentBadge);
    final newRank = _getBadgeRank(newBadge);

    // Only save the new badge if it's of a higher rank.
    if (newRank > currentRank) {
      _saveQuizProgress(newBadge);
    } else {
      // If the new badge is not a higher rank, we still need to stop the loading state.
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _getBadgeRank(String badge) {
    switch (badge) {
      case 'Gold':
        return 3;
      case 'Silver':
        return 2;
      case 'Bronze':
        return 1;
      default:
        return 0;
    }
  }

  Future<void> _saveQuizProgress(String badge) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      await userProfileProvider.updateQuizProgress(badge);
    } catch (e) {
      debugPrint('Error saving quiz progress: $e');
    } finally {
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _getBadgeColor(String badge) {
    switch (badge) {
      case 'Gold':
        return Colors.amber;
      case 'Silver':
        return Colors.blueGrey.shade300;
      case 'Bronze':
        return Colors.brown.shade400;
      default:
        return AppColors.textSecondaryDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
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
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: AppTheme.applyGlassmorphism(
                blurX: 15,
                blurY: 15,
                opacity: 0.1,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingExtraLarge),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Quiz Complete!',
                        style: AppTextStyles.heading1.copyWith(color: AppColors.textPrimaryDark),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      Text(
                        'You scored ${widget.score} out of ${widget.totalQuestions}',
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondaryDark),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.paddingExtraLarge),
                      Text(
                        _quizBadge == 'None' ? 'Better Luck Next Time' : 'Congratulations!',
                        style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimaryDark),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      // Display the badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
                        decoration: BoxDecoration(
                          color: _getBadgeColor(_quizBadge).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                          border: Border.all(color: _getBadgeRank(_quizBadge)>0 ? _getBadgeColor(_quizBadge) : AppColors.textPrimaryDark.withOpacity(0.1)),
                        ),
                        child: Text(
                          _quizBadge,
                          style: AppTextStyles.heading3.copyWith(color: _getBadgeColor(_quizBadge)),
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingExtraLarge),
                      CustomButton(
                        text: 'RETURN TO HOME',
                        onPressed: _isLoading
                            ? null
                            : () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            HomeScreen.routeName,
                                (Route<dynamic> route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            const LoadingWidget(isFullScreen: true),
        ],
      ),
    );
  }
}
