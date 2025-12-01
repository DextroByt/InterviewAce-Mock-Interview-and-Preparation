// lib/screens/interview/interview_setup_screen.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/helpers.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/interview_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_widget.dart';
import '../../models/interview_model.dart';

import 'interview_screen.dart';
import '../home/home_screen.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';

class InterviewSetupScreen extends StatefulWidget {
  static const String routeName = '/interview-setup';

  const InterviewSetupScreen({super.key});

  @override
  State<InterviewSetupScreen> createState() => _InterviewSetupScreenState();
}

class _InterviewSetupScreenState extends State<InterviewSetupScreen> {
  String? _selectedJobRole;
  String? _selectedDifficulty;
  int _numberOfQuestions = 5;
  String _aiInterviewerGender = 'male';

  final List<String> _jobRoles = ['Cybersecurity', 'Data Scientist', 'DevOps Engineer', 'Software Engineer', 'Web Developer'];
  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];
  final List<int> _questionCounts = [3, 5, 10, 15];
  final List<String> _aiGenders = ['male', 'female'];

  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      if (userProfileProvider.userProfile != null && userProfileProvider.userProfile!.careerGoals.isNotEmpty) {
        final firstGoal = userProfileProvider.userProfile!.careerGoals.first;
        if (_jobRoles.any((role) => role.toLowerCase() == firstGoal.toLowerCase())) {
          setState(() {
            _selectedJobRole = _jobRoles.firstWhere((role) => role.toLowerCase() == firstGoal.toLowerCase());
          });
        }
      }
    });
  }

  Future<void> _startInterview() async {
    if (_selectedJobRole == null || _selectedDifficulty == null) {
      Helpers.showSnackbar(context, 'Please select a job role and difficulty.', backgroundColor: AppColors.error);
      return;
    }

    final interviewProvider = Provider.of<InterviewProvider>(context, listen: false);
    final userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false); // Get UserProfileProvider

    try {
      final config = InterviewConfig(
        jobRole: _selectedJobRole!,
        difficulty: _selectedDifficulty!,
        numberOfQuestions: _numberOfQuestions,
        aiInterviewerGender: _aiInterviewerGender,
      );

      // Pass the UserProfileProvider to the startInterview method
      await interviewProvider.startInterview(config, userProfileProvider);

      Helpers.showSnackbar(context, 'Preparing your interview...', backgroundColor: AppColors.info);
      Navigator.of(context).pushReplacementNamed(InterviewScreen.routeName);
    } catch (e) {
      Helpers.showSnackbar(context, 'Failed to start interview: $e', backgroundColor: AppColors.error);
    }
  }

  // ... rest of the file remains the same
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed(HistoryScreen.routeName);
        break;
      case 2:
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed(SettingsScreen.routeName);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final interviewProvider = Provider.of<InterviewProvider>(context);

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
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + AppConstants.paddingExtraLarge,
                left: AppConstants.paddingLarge,
                right: AppConstants.paddingLarge,
                bottom: AppConstants.paddingLarge + 80,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Configure Your Mock Interview',
                    style: AppTextStyles.heading1.copyWith(color: AppColors.textPrimaryDark),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.paddingExtraLarge * 1.5),
                  AppTheme.applyGlassmorphism(
                    blurX: 15.0,
                    blurY: 15.0,
                    opacity: 0.1,
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Select Job Role',
                            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryDark),
                          ),
                          const SizedBox(height: AppConstants.paddingSmall),
                          _buildDropdownField<String>(
                            context: context,
                            value: _selectedJobRole,
                            hint: 'Select a job role',
                            items: _jobRoles,
                            onChanged: (newValue) {
                              setState(() {
                                _selectedJobRole = newValue;
                              });
                            },
                          ),
                          const SizedBox(height: AppConstants.paddingLarge),
                          Text(
                            'Difficulty Level',
                            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryDark),
                          ),
                          const SizedBox(height: AppConstants.paddingSmall),
                          _buildSelectionChips<String>(
                            context: context,
                            options: _difficulties,
                            selectedValue: _selectedDifficulty,
                            onSelected: (value) {
                              setState(() {
                                _selectedDifficulty = value;
                              });
                            },
                          ),
                          const SizedBox(height: AppConstants.paddingLarge),
                          Text(
                            'Number of Questions',
                            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryDark),
                          ),
                          const SizedBox(height: AppConstants.paddingSmall),
                          _buildSelectionChips<int>(
                            context: context,
                            options: _questionCounts,
                            selectedValue: _numberOfQuestions,
                            onSelected: (value) {
                              setState(() {
                                _numberOfQuestions = value!;
                              });
                            },
                          ),
                          const SizedBox(height: AppConstants.paddingLarge),
                          Text(
                            'AI Interviewer Gender',
                            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryDark),
                          ),
                          const SizedBox(height: AppConstants.paddingSmall),
                          _buildSelectionChips<String>(
                            context: context,
                            options: _aiGenders,
                            selectedValue: _aiInterviewerGender,
                            onSelected: (value) {
                              setState(() {
                                _aiInterviewerGender = value!;
                              });
                            },
                          ),
                          const SizedBox(height: AppConstants.paddingExtraLarge),
                          CustomButton(
                            text: 'START INTERVIEW',
                            onPressed: _startInterview,
                            isLoading: interviewProvider.isLoadingQuestions,
                            icon: const Icon(Icons.play_arrow, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (interviewProvider.isLoadingQuestions)
            const LoadingWidget(
              isFullScreen: true,
              message: 'Generating questions...',
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.borderRadiusLarge)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: BottomNavigationBar(
          backgroundColor: AppColors.backgroundDark.withOpacity(0.5),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: AppColors.primaryLight,
          unselectedItemColor: AppColors.textSecondaryDark.withOpacity(0.6),
          type: BottomNavigationBarType.fixed,
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
              icon: Icon(Icons.mic),
              label: 'Interview',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionChips<T>({
    required BuildContext context,
    required List<T> options,
    required T? selectedValue,
    required ValueChanged<T?> onSelected,
  }) {
    return Wrap(
      spacing: AppConstants.paddingSmall,
      runSpacing: AppConstants.paddingSmall,
      children: options.map((option) {
        final bool isSelected = option == selectedValue;
        return ChoiceChip(
          label: Text(
            option.toString(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? AppColors.backgroundDark : AppColors.textPrimaryDark,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              onSelected(option);
            }
          },
          selectedColor: AppColors.primaryLight,
          backgroundColor: AppColors.surfaceDark.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            side: BorderSide(
              color: isSelected
                  ? AppColors.primaryLight
                  : AppColors.textSecondaryDark.withOpacity(0.3),
              width: 1,
            ),
          ),
          elevation: isSelected ? 4 : 0,
          shadowColor: Colors.black.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingSmall,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDropdownField<T>({
    required BuildContext context,
    required T? value,
    required String hint,
    required List<T> items,
    required ValueChanged<T?>? onChanged,
    bool isDisabled = false,
  }) {
    return AppTheme.applyGlassmorphism(
      blurX: 5.0,
      blurY: 5.0,
      opacity: 0.1,
      child: DropdownButtonFormField<T>(
        value: value,
        hint: Text(
          hint,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDisabled ? AppColors.textSecondaryDark.withOpacity(0.4) : AppColors.textSecondaryDark,
          ),
        ),
        dropdownColor: AppColors.backgroundDark.withOpacity(0.8),
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
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
        ),
        icon: Icon(Icons.arrow_drop_down, color: isDisabled ? AppColors.textSecondaryDark.withOpacity(0.4) : AppColors.primaryLight),
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<T>>((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              item.toString(),
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
            ),
          );
        }).toList(),
      ),
    );
  }
}
