// lib/screens/learn/quiz_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../data/quiz_questions_data.dart';
import '../../services/free_ai_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_widget.dart';
import 'quiz_results_screen.dart';


class QuizScreen extends StatefulWidget {
  static const String routeName = '/quiz';

  final String jobRole;
  final String difficulty;

  const QuizScreen({
    super.key,
    required this.jobRole,
    required this.difficulty,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  final _random = Random();
  late FreeAiService _aiService;
  late AnimationController _cardAnimationController;
  late Animation<double> _cardFadeAnimation;
  late Animation<Offset> _cardSlideAnimation;

  List<String> _questions = [];
  Map<String, String> _answers = {};
  Map<String, List<String>> _options = {};

  int _currentQuestionIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _aiService = Provider.of<FreeAiService>(context, listen: false);
    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _cardFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.easeIn),
    );
    _cardSlideAnimation = Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.easeOutCubic),
    );

    _loadQuizData();
  }

  // Load questions and generate answer options
  Future<void> _loadQuizData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final questionsAndAnswers =
      quizQuestionsData[widget.jobRole]![widget.difficulty]!;
      _questions = questionsAndAnswers.map((q) => q['question']!).toList();
      _answers = {
        for (var q in questionsAndAnswers) q['question']!: q['answer']!
      };

      // For each question, generate a correct solution and 3 incorrect options.
      for (final question in _questions) {
        final options = await _aiService.generateQuizOptions(
          question: question,
          correctAnswer: _answers[question]!,
        );
        options.shuffle(_random);
        _options[question] = options;
      }
    } catch (e) {
      debugPrint('Error loading quiz data: $e');
      if (mounted) {
        Helpers.showSnackbar(context, 'Failed to load quiz. Please try again.',
            backgroundColor: AppColors.error);
      }
      _questions = [];
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Handles moving to the next question or finishing the quiz
  void _handleNext() async {
    if (_selectedAnswer != null) {
      _isProcessing = true;
      final currentQuestion = _questions[_currentQuestionIndex];
      if (_selectedAnswer!.toLowerCase() == _answers[currentQuestion]!.toLowerCase()) {
        _score++;
      }

      if (_currentQuestionIndex < _questions.length - 1) {
        // Animate the card out before moving to the next question
        await _cardAnimationController.reverse(from: 1.0);
        setState(() {
          _currentQuestionIndex++;
          _selectedAnswer = null;
          _isProcessing = false;
        });
        // Animate the new card in
        _cardAnimationController.forward(from: 0.0);
      } else {
        _finishQuiz();
      }
    }
  }

  // Finalizes the quiz and navigates to the results screen
  void _finishQuiz() {
    _isProcessing = false;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => QuizResultsScreen(
          score: _score,
          totalQuestions: _questions.length,
          jobRole: widget.jobRole,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: LoadingWidget(isFullScreen: true, message: 'Generating quiz...'),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          title: Text(
            '${widget.jobRole} Quiz',
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
        body: Center(
          child: AppTheme.applyGlassmorphism(
            blurX: 10.0,
            blurY: 10.0,
            opacity: 0.15,
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Text(
                'Failed to load quiz questions.',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondaryDark),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    // Start the animation for the first question
    _cardAnimationController.forward(from: 0.0);

    final currentQuestionText = _questions[_currentQuestionIndex];
    final currentOptions = _options[currentQuestionText] ?? [];

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          '${widget.jobRole} Quiz',
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProgressIndicator(),
                  const SizedBox(height: AppConstants.paddingLarge),
                  Expanded(
                    child: FadeTransition(
                      opacity: _cardFadeAnimation,
                      child: SlideTransition(
                        position: _cardSlideAnimation,
                        child: _buildQuestionCard(currentQuestionText, currentOptions),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                  CustomButton(
                    text: _currentQuestionIndex == _questions.length - 1
                        ? 'FINISH QUIZ'
                        : 'NEXT QUESTION',
                    onPressed: (_selectedAnswer == null || _isProcessing) ? null : _handleNext,
                    isLoading: _isProcessing,
                    isSecondary: _selectedAnswer != null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return AppTheme.applyGlassmorphism(
      blurX: 5,
      blurY: 5,
      opacity: 0.1,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
              child: LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / _questions.length,
                backgroundColor: AppColors.surfaceDark.withOpacity(0.5),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
                minHeight: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(String questionText, List<String> options) {
    return AppTheme.applyGlassmorphism(
      blurX: 10,
      blurY: 10,
      opacity: 0.15,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              questionText,
              style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimaryDark),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = _selectedAnswer == option;

                  // Define colors based on selection and processing state
                  Color containerColor;
                  Color borderColor;
                  Color iconColor;
                  if (isSelected) {
                    containerColor = AppColors.primaryLight.withOpacity(0.2);
                    borderColor = AppColors.primaryLight;
                    iconColor = AppColors.primaryLight;
                  } else {
                    containerColor = AppColors.surfaceDark.withOpacity(0.2);
                    borderColor = AppColors.textSecondaryDark.withOpacity(0.3);
                    iconColor = AppColors.textSecondaryDark;
                  }

                  if (_isProcessing) {
                    final isCorrect = option == _answers[questionText];
                    final isWrong = !isCorrect && isSelected;

                    if (isCorrect) {
                      borderColor = AppColors.success;
                      iconColor = AppColors.success;
                    } else if (isWrong) {
                      borderColor = AppColors.error;
                      iconColor = AppColors.error;
                    }
                  }


                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall / 2),
                    child: InkWell(
                      onTap: _isProcessing
                          ? null
                          : () {
                        setState(() {
                          _selectedAnswer = option;
                        });
                      },
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingMedium),
                        decoration: BoxDecoration(
                          color: containerColor,
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                          border: Border.all(
                            color: borderColor,
                            width: isSelected ? 2 : 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                              color: iconColor,
                            ),
                            const SizedBox(width: AppConstants.paddingMedium),
                            Expanded(
                              child: Text(
                                option,
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
