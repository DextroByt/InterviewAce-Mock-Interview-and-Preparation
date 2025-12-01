// lib/screens/prepare/prepare_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui'; // For ImageFilter.blur
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart'; // For showSnackbar if needed
import '../../data/question_solutions_data.dart'; // Import the new data file
import '../../services/free_ai_service.dart'; // NEW: Import FreeAiService
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_widget.dart';

import '../learn/quiz_screen.dart';
import '../home/home_screen.dart';
import '../history/history_screen.dart';
import '../interview/interview_setup_screen.dart';
import '../settings/settings_screen.dart';


class PrepareScreen extends StatefulWidget {
  static const String routeName = '/prepare';

  const PrepareScreen({super.key});

  @override
  State<PrepareScreen> createState() => _PrepareScreenState();
}

class _PrepareScreenState extends State<PrepareScreen> {
  String? _selectedJobRole;
  String? _selectedDifficulty;
  List<Map<String, String>> _filteredQuestions = [];

  // NEW: Maps to store fetched solutions and their loading states
  final Map<String, String> _fetchedSolutions = {};
  final Map<String, bool> _isLoadingSolution = {};

  final List<String> _jobRoles = interviewQuestionSolutionsData.keys.toList();
  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];

  int _selectedIndex = 0;

  late FreeAiService _aiService;

  @override
  void initState() {
    super.initState();
    if (_jobRoles.isNotEmpty) {
      _selectedJobRole = _jobRoles.first;
      if (_difficulties.isNotEmpty) {
        _selectedDifficulty = _difficulties.first;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _aiService = Provider.of<FreeAiService>(context, listen: false);
      _filterQuestions();
    });
  }

  // Filters questions based on selected job role and difficulty
  void _filterQuestions() {
    setState(() {
      _filteredQuestions = [];
      if (_selectedJobRole != null && _selectedDifficulty != null) {
        final jobRoleData = interviewQuestionSolutionsData[_selectedJobRole];
        if (jobRoleData != null) {
          final difficultyData = jobRoleData[_selectedDifficulty];
          if (difficultyData != null) {
            _filteredQuestions = difficultyData.map((q) => {'question': q['question']!}).toList();
          }
        }
      }
      _fetchedSolutions.clear();
      _isLoadingSolution.clear();
    });
  }

  // NEW: Fetches the solution for a given question using the AI service
  Future<void> _fetchSolution(String questionText) async {
    if (_fetchedSolutions.containsKey(questionText) || _isLoadingSolution[questionText] == true) {
      return;
    }

    setState(() {
      _isLoadingSolution[questionText] = true;
    });

    try {
      final solution = await _aiService.generateQuestionSolution(question: questionText);
      setState(() {
        _fetchedSolutions[questionText] = solution;
      });
    } catch (e) {
      debugPrint('Error fetching solution: $e');
      if (mounted) {
        Helpers.showSnackbar(context, 'Failed to load solution: $e', backgroundColor: AppColors.error);
      }
      setState(() {
        _fetchedSolutions[questionText] = 'Failed to load solution. Please try again.';
      });
    } finally {
      setState(() {
        _isLoadingSolution[questionText] = false;
      });
    }
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

  // NEW: Widget to build the Quiz section card
  Widget _buildQuizCard(BuildContext context) {
    return AppTheme.applyGlassmorphism(
      blurX: 10.0,
      blurY: 10.0,
      opacity: 0.15,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Test Your Knowledge with Quizzes',
                    style: AppTextStyles.heading3.copyWith(color: AppColors.primaryLight),
                  ),
                ),
                Icon(Icons.quiz_outlined, color: AppColors.secondaryLight, size: AppConstants.iconSizeLarge * 1.5),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'Select a job role and difficulty to start a quick quiz and earn badges!',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildDropdownField<String>(
              context: context,
              value: _selectedJobRole,
              hint: 'Select Job Role',
              items: _jobRoles,
              onChanged: (newValue) {
                setState(() {
                  _selectedJobRole = newValue;
                  _filterQuestions();
                });
              },
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            _buildDropdownField<String>(
              context: context,
              value: _selectedDifficulty,
              hint: 'Select Difficulty',
              items: _difficulties,
              onChanged: (newValue) {
                setState(() {
                  _selectedDifficulty = newValue;
                  _filterQuestions();
                });
              },
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            CustomButton(
              text: 'START QUIZ',
              onPressed: () {
                if (_selectedJobRole != null && _selectedDifficulty != null) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => QuizScreen(
                      jobRole: _selectedJobRole!,
                      difficulty: _selectedDifficulty!,
                    ),
                  ));
                } else {
                  Helpers.showSnackbar(context, 'Please select a job role and difficulty.', backgroundColor: AppColors.error);
                }
              },
              icon: const Icon(Icons.play_arrow, color: AppColors.backgroundDark),
            ),
          ],
        ),
      ),
    );
  }

  // NEW: Widget to build the Question & Solutions browsing section
  Widget _buildQuestionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppConstants.paddingExtraLarge),
        Text(
          'Browse Questions & Solutions',
          style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimaryDark),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        _filteredQuestions.isEmpty
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Text(
              'No questions found for the selected criteria. Please select a job role and difficulty to see questions.',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondaryDark),
              textAlign: TextAlign.center,
            ),
          ),
        )
            : AnimationLimiter(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredQuestions.length,
            itemBuilder: (context, index) {
              final questionData = _filteredQuestions[index];
              final questionText = questionData['question']!;
              final bool solutionLoading = _isLoadingSolution[questionText] ?? false;
              final String? solution = _fetchedSolutions[questionText];

              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                      child: AppTheme.applyGlassmorphism(
                        blurX: 8.0, blurY: 8.0, opacity: 0.1,
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: AppConstants.paddingSmall),
                            collapsedIconColor: AppColors.textSecondaryDark,
                            iconColor: AppColors.primaryLight,
                            title: Text(
                              'Question ${index + 1}: $questionText',
                              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onExpansionChanged: (isExpanded) {
                              if (isExpanded && solution == null && !solutionLoading) {
                                _fetchSolution(questionText);
                              }
                            },
                            childrenPadding: const EdgeInsets.all(AppConstants.paddingLarge),
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Solution:',
                                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.secondaryLight, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: AppConstants.paddingSmall),
                                  solutionLoading
                                      ? const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
                                      strokeWidth: 2,
                                    ),
                                  )
                                      : Text(
                                    solution ?? 'Expand to load solution.',
                                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          'Learn Hub',
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
                _buildQuizCard(context),
                _buildQuestionList(),
                const SizedBox(height: AppConstants.paddingExtraLarge),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
}
