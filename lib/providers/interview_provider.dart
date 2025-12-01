// lib/providers/interview_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/helpers.dart';
import '../models/interview_model.dart';
import '../models/question_model.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../services/free_ai_service.dart';
import '../services/free_speech_analyzer.dart';
import '../services/free_report_service.dart';
import '../services/free_database_service.dart';
import '../services/free_emotion_service.dart';
import '../core/constants/app_constants.dart';
import 'user_profile_provider.dart';

class InterviewProvider with ChangeNotifier {
  final FreeAiService _aiService;
  final StorageService _storageService;
  final FreeSpeechAnalyzer _speechAnalyzer;
  final FreeReportService _reportService;
  final FreeDatabaseService _databaseService;
  final FreeEmotionService _emotionService;

  InterviewModel? _currentInterview;
  String? _greetingMessage;
  int _currentQuestionIndex = -1;
  bool _isLoadingQuestions = false;
  bool _isInterviewActive = false;
  bool _isProcessingResponse = false;
  List<InterviewModel> _interviewHistory = [];

  // Getters
  InterviewModel? get currentInterview => _currentInterview;
  String? get greetingMessage => _greetingMessage;

  // FIX: Restored the public getter for interviewHistory.
  List<InterviewModel> get interviewHistory => _interviewHistory;

  QuestionModel? get currentQuestion {
    if (_currentInterview == null || _currentQuestionIndex < 0 || _currentQuestionIndex >= _currentInterview!.questionsAndAnswers.length) {
      return null;
    }
    return QuestionModel(
      id: _currentInterview!.questionsAndAnswers[_currentQuestionIndex].questionText.hashCode.toString(),
      text: _currentInterview!.questionsAndAnswers[_currentQuestionIndex].questionText,
      category: 'General',
      difficulty: 'Medium',
    );
  }
  bool get isLoadingQuestions => _isLoadingQuestions;
  bool get isInterviewActive => _isInterviewActive;
  bool get isProcessingResponse => _isProcessingResponse;
  int get currentQuestionNumber => _currentQuestionIndex + 1;
  int get totalQuestions => _currentInterview?.config.numberOfQuestions ?? 0;

  InterviewProvider()
      : _aiService = FreeAiService(apiService: ApiService(baseUrl: AppConstants.geminiApiBaseUrl, apiKey: AppConstants.geminiApiKey)),
        _storageService = StorageService(),
        _speechAnalyzer = FreeSpeechAnalyzer(),
        _reportService = FreeReportService(),
        _databaseService = FreeDatabaseService(),
        _emotionService = FreeEmotionService() {
    _storageService.init();
  }

  Future<void> startInterview(InterviewConfig config, UserProfileProvider userProfileProvider) async {
    _setLoadingQuestions(true);
    _isInterviewActive = false;
    _greetingMessage = null;

    try {
      final String interviewId = const Uuid().v4();
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      final String userName = userProfileProvider.userProfile?.displayName ?? 'Candidate';

      if (userId == null) {
        throw Exception('User not authenticated.');
      }

      final results = await Future.wait([
        _aiService.generateGreeting(userName: userName, jobRole: config.jobRole),
        _aiService.generateInterviewQuestions(
          jobRole: config.jobRole,
          difficulty: config.difficulty,
          count: config.numberOfQuestions,
        ),
      ]);

      _greetingMessage = results[0] as String;
      final generatedQuestions = results[1] as List<QuestionModel>;

      if (generatedQuestions.isEmpty) {
        throw Exception('No questions generated. Please try again.');
      }

      final List<QuestionAnswer> initialQuestionsAndAnswers = generatedQuestions.map((q) => QuestionAnswer(
        questionText: q.text,
        userResponse: '',
        questionTimestamp: DateTime.now(),
        responseTimestamp: DateTime.now(),
      )).toList();

      _currentInterview = InterviewModel(
        id: interviewId,
        userId: userId,
        timestamp: DateTime.now(),
        config: config,
        questionsAndAnswers: initialQuestionsAndAnswers,
        analysis: null,
      );
      _currentQuestionIndex = -1;
      _isInterviewActive = true;
      debugPrint('Interview ready with greeting: $_greetingMessage');
    } catch (e) {
      debugPrint('Error starting interview: $e');
      _currentInterview = null;
      _isInterviewActive = false;
      rethrow;
    } finally {
      _setLoadingQuestions(false);
    }
    notifyListeners();
  }

  bool nextQuestion() {
    if (_currentInterview == null) return false;
    if (_currentQuestionIndex < _currentInterview!.questionsAndAnswers.length - 1) {
      _currentQuestionIndex++;
      debugPrint('Moving to question: ${_currentQuestionIndex + 1}');
      notifyListeners();
      return true;
    } else {
      debugPrint('No more questions. Interview will end.');
      return false;
    }
  }

  Future<void> submitResponse(String response) async {
    if (_currentInterview == null || _currentQuestionIndex >= _currentInterview!.questionsAndAnswers.length || _currentQuestionIndex < 0) {
      debugPrint('No active question to submit response for.');
      return;
    }

    _isProcessingResponse = true;
    notifyListeners();

    try {
      final currentQA = _currentInterview!.questionsAndAnswers[_currentQuestionIndex];
      final updatedQA = currentQA.copyWith(
        userResponse: response,
        responseTimestamp: DateTime.now(),
      );

      final speechAnalysisResult = await _speechAnalyzer.analyzeSpeech(
        response,
        updatedQA.responseTimestamp.difference(currentQA.questionTimestamp).abs(),
      );

      final Map<String, double> emotionAnalysisResult = await _emotionService.analyzeEmotion(response);

      final String questionFeedback = await _aiService.generateQuestionFeedback(
        question: currentQA.questionText,
        userResponse: response,
        analysis: speechAnalysisResult,
        emotionData: emotionAnalysisResult,
      );

      final questionAnalysis = QuestionAnalysis(
        speakingRateWPM: speechAnalysisResult['speakingRateWPM'] ?? 0.0,
        fillerWordCount: speechAnalysisResult['fillerWordCount'] ?? 0,
        clarityScore: speechAnalysisResult['clarityScore'] ?? 0.0,
        emotionDetected: emotionAnalysisResult,
        feedback: questionFeedback,
      );

      _currentInterview!.questionsAndAnswers[_currentQuestionIndex] = updatedQA.copyWith(
        analysis: questionAnalysis,
      );
      debugPrint('Response submitted for question ${_currentQuestionIndex + 1}');
    } catch (e) {
      debugPrint('Error processing response: $e');
    } finally {
      _isProcessingResponse = false;
      notifyListeners();
    }
  }

  Future<void> endInterview() async {
    if (_currentInterview == null) return;
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    _setProcessingResponse(true);
    _isInterviewActive = false;
    debugPrint('Ending interview and generating report...');

    try {
      final analyses = _currentInterview!.questionsAndAnswers
          .map((qa) => qa.analysis)
          .where((a) => a != null)
          .cast<QuestionAnalysis>()
          .toList();

      final double overallSpeakingRateWPM = analyses.isNotEmpty ? analyses.map((a) => a.speakingRateWPM).reduce((a, b) => a + b) / analyses.length : 0.0;
      final int totalFillerWordCount = analyses.isNotEmpty ? analyses.map((a) => a.fillerWordCount).reduce((a, b) => a + b) : 0;
      final double averageClarityScore = analyses.isNotEmpty ? analyses.map((a) => a.clarityScore).reduce((a, b) => a + b) / analyses.length : 0.0;
      final Map<String, double> dominantEmotions = {};
      for (var analysis in analyses) {
        analysis.emotionDetected.forEach((emotion, score) {
          dominantEmotions.update(emotion, (value) => value + score, ifAbsent: () => score);
        });
      }
      if (dominantEmotions.isNotEmpty) {
        final double totalEmotionScore = dominantEmotions.values.reduce((sum, score) => sum + score);
        if (totalEmotionScore > 0) {
          dominantEmotions.forEach((key, value) {
            dominantEmotions[key] = value / totalEmotionScore;
          });
        }
      }

      final aiFeedback = await _aiService.generateOverallInterviewFeedback(
        overallSpeakingRateWPM: overallSpeakingRateWPM,
        totalFillerWordCount: totalFillerWordCount,
        averageClarityScore: averageClarityScore,
        interviewConfig: _currentInterview!.config,
        questionsAndAnswers: _currentInterview!.questionsAndAnswers,
      );

      final overallAnalysis = InterviewAnalysis(
        overallSpeakingRateWPM: overallSpeakingRateWPM,
        totalFillerWordCount: totalFillerWordCount,
        averageClarityScore: averageClarityScore,
        dominantEmotions: dominantEmotions,
        overallFeedback: aiFeedback['overallFeedback'] ?? 'Could not generate AI feedback.',
        suggestionsForImprovement: List<String>.from(aiFeedback['suggestions'] ?? []),
      );

      _currentInterview = _currentInterview!.copyWith(analysis: overallAnalysis);
      await _databaseService.addInterviewHistory(userId, _currentInterview!.toJson());
      debugPrint('Interview ended. Report generated.');
    } catch (e) {
      debugPrint('Error ending interview: $e');
    } finally {
      _setProcessingResponse(false);
      notifyListeners();
    }
  }

  Future<void> fetchInterviewHistory(BuildContext context) async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _interviewHistory = [];
      notifyListeners();
      return;
    }
    try {
      _setLoadingQuestions(true);
      final List<Map<String, dynamic>> historyData = await _databaseService.getInterviewHistory(userId);
      _interviewHistory = historyData.map((e) => InterviewModel.fromJson(e)).toList();
      _interviewHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      debugPrint('Error fetching history: $e');
      Helpers.showSnackbar(context, 'Failed to load interview history.', backgroundColor: AppColors.error);
      _interviewHistory = [];
    } finally {
      _setLoadingQuestions(false);
      notifyListeners();
    }
  }

  void setCurrentInterview(InterviewModel interview) {
    _currentInterview = interview;
    _currentQuestionIndex = 0;
    _isInterviewActive = false;
    notifyListeners();
  }

  void resetInterview() {
    _currentInterview = null;
    _greetingMessage = null;
    _currentQuestionIndex = -1;
    _isInterviewActive = false;
    _isLoadingQuestions = false;
    _isProcessingResponse = false;
    debugPrint('Interview state reset.');
    notifyListeners();
  }

  void _setLoadingQuestions(bool value) {
    _isLoadingQuestions = value;
    notifyListeners();
  }

  void _setProcessingResponse(bool value) {
    _isProcessingResponse = value;
    notifyListeners();
  }
}
