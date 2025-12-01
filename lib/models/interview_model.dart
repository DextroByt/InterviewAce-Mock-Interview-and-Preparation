// lib/models/interview_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

// This file defines the data structure for an interview session.
// It includes properties for the interview's configuration, questions asked,
// user responses, and performance metrics.

class InterviewModel {
  final String id; // Unique ID for this interview session
  final String userId; // ID of the user who took the interview
  final DateTime timestamp; // When the interview was conducted
  final InterviewConfig config; // Configuration settings for this interview
  final List<QuestionAnswer> questionsAndAnswers; // List of questions and user responses
  final InterviewAnalysis? analysis; // Overall analysis and report of the interview

  InterviewModel({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.config,
    required this.questionsAndAnswers,
    this.analysis,
  });

  factory InterviewModel.fromJson(Map<String, dynamic> json) {
    try {
      return InterviewModel(
        id: json['id'] as String? ?? '', // FIX: Handle potential null
        userId: json['userId'] as String? ?? '', // FIX: Handle potential null
        timestamp: (json['timestamp'] is Timestamp)
            ? (json['timestamp'] as Timestamp).toDate()
            : DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(), // FIX: Handle potential null
        config: InterviewConfig.fromJson(json['config'] as Map<String, dynamic>? ?? {}), // FIX: Handle potential null
        questionsAndAnswers: (json['questionsAndAnswers'] as List<dynamic>?)
            ?.map((e) => QuestionAnswer.fromJson(e as Map<String, dynamic>? ?? {}))
            .toList() ?? [], // FIX: Handle potential null
        analysis: json['analysis'] != null
            ? InterviewAnalysis.fromJson(json['analysis'] as Map<String, dynamic>? ?? {})
            : null,
      );
    } catch (e) {
      debugPrint('Error parsing InterviewModel from JSON: $e, JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'config': config.toJson(),
      'questionsAndAnswers': questionsAndAnswers.map((qa) => qa.toJson()).toList(),
      'analysis': analysis?.toJson(),
    };
  }

  InterviewModel copyWith({
    String? id,
    String? userId,
    DateTime? timestamp,
    InterviewConfig? config,
    List<QuestionAnswer>? questionsAndAnswers,
    InterviewAnalysis? analysis,
  }) {
    return InterviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      config: config ?? this.config,
      questionsAndAnswers: questionsAndAnswers ?? this.questionsAndAnswers,
      analysis: analysis ?? this.analysis,
    );
  }
}

class InterviewConfig {
  final String jobRole;
  final String difficulty;
  final int numberOfQuestions;
  final String aiInterviewerGender;

  InterviewConfig({
    required this.jobRole,
    required this.difficulty,
    required this.numberOfQuestions,
    required this.aiInterviewerGender,
  });

  factory InterviewConfig.fromJson(Map<String, dynamic> json) {
    return InterviewConfig(
      // FIX: Provide default values if a field is null to prevent crashes from old data.
      jobRole: json['jobRole'] as String? ?? json['field'] as String? ?? 'General', // Backward compatible with 'field'
      difficulty: json['difficulty'] as String? ?? 'Medium',
      numberOfQuestions: json['numberOfQuestions'] as int? ?? 5,
      aiInterviewerGender: json['aiInterviewerGender'] as String? ?? 'male',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobRole': jobRole,
      'difficulty': difficulty,
      'numberOfQuestions': numberOfQuestions,
      'aiInterviewerGender': aiInterviewerGender,
    };
  }
}

class QuestionAnswer {
  final String questionText;
  final String userResponse;
  final DateTime questionTimestamp;
  final DateTime responseTimestamp;
  final QuestionAnalysis? analysis;

  QuestionAnswer({
    required this.questionText,
    required this.userResponse,
    required this.questionTimestamp,
    required this.responseTimestamp,
    this.analysis,
  });

  factory QuestionAnswer.fromJson(Map<String, dynamic> json) {
    return QuestionAnswer(
      questionText: json['questionText'] as String? ?? 'Question not found', // FIX: Handle null
      userResponse: json['userResponse'] as String? ?? '', // FIX: Handle null
      questionTimestamp: (json['questionTimestamp'] is Timestamp)
          ? (json['questionTimestamp'] as Timestamp).toDate()
          : DateTime.tryParse(json['questionTimestamp'] as String? ?? '') ?? DateTime.now(), // FIX: Handle null
      responseTimestamp: (json['responseTimestamp'] is Timestamp)
          ? (json['responseTimestamp'] as Timestamp).toDate()
          : DateTime.tryParse(json['responseTimestamp'] as String? ?? '') ?? DateTime.now(), // FIX: Handle null
      analysis: json['analysis'] != null
          ? QuestionAnalysis.fromJson(json['analysis'] as Map<String, dynamic>? ?? {})
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionText': questionText,
      'userResponse': userResponse,
      'questionTimestamp': questionTimestamp.toIso8601String(),
      'responseTimestamp': responseTimestamp.toIso8601String(),
      'analysis': analysis?.toJson(),
    };
  }

  QuestionAnswer copyWith({
    String? questionText,
    String? userResponse,
    DateTime? questionTimestamp,
    DateTime? responseTimestamp,
    QuestionAnalysis? analysis,
  }) {
    return QuestionAnswer(
      questionText: questionText ?? this.questionText,
      userResponse: userResponse ?? this.userResponse,
      questionTimestamp: questionTimestamp ?? this.questionTimestamp,
      responseTimestamp: responseTimestamp ?? this.responseTimestamp,
      analysis: analysis ?? this.analysis,
    );
  }
}

class QuestionAnalysis {
  final double speakingRateWPM;
  final int fillerWordCount;
  final double clarityScore;
  final Map<String, double> emotionDetected;
  final String feedback;

  QuestionAnalysis({
    required this.speakingRateWPM,
    required this.fillerWordCount,
    required this.clarityScore,
    required this.emotionDetected,
    required this.feedback,
  });

  factory QuestionAnalysis.fromJson(Map<String, dynamic> json) {
    return QuestionAnalysis(
      speakingRateWPM: (json['speakingRateWPM'] as num?)?.toDouble() ?? 0.0,
      fillerWordCount: json['fillerWordCount'] as int? ?? 0,
      clarityScore: (json['clarityScore'] as num?)?.toDouble() ?? 0.0,
      emotionDetected: Map<String, double>.from(json['emotionDetected'] as Map? ?? {}),
      feedback: json['feedback'] as String? ?? 'No feedback available.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speakingRateWPM': speakingRateWPM,
      'fillerWordCount': fillerWordCount,
      'clarityScore': clarityScore,
      'emotionDetected': emotionDetected,
      'feedback': feedback,
    };
  }
}

class InterviewAnalysis {
  final double overallSpeakingRateWPM;
  final int totalFillerWordCount;
  final double averageClarityScore;
  final Map<String, double> dominantEmotions;
  final String overallFeedback;
  final List<String> suggestionsForImprovement;

  InterviewAnalysis({
    required this.overallSpeakingRateWPM,
    required this.totalFillerWordCount,
    required this.averageClarityScore,
    required this.dominantEmotions,
    required this.overallFeedback,
    required this.suggestionsForImprovement,
  });

  factory InterviewAnalysis.fromJson(Map<String, dynamic> json) {
    return InterviewAnalysis(
      overallSpeakingRateWPM: (json['overallSpeakingRateWPM'] as num?)?.toDouble() ?? 0.0,
      totalFillerWordCount: json['totalFillerWordCount'] as int? ?? 0,
      averageClarityScore: (json['averageClarityScore'] as num?)?.toDouble() ?? 0.0,
      dominantEmotions: Map<String, double>.from(json['dominantEmotions'] as Map? ?? {}),
      overallFeedback: json['overallFeedback'] as String? ?? 'No overall feedback available.',
      suggestionsForImprovement: (json['suggestionsForImprovement'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overallSpeakingRateWPM': overallSpeakingRateWPM,
      'totalFillerWordCount': totalFillerWordCount,
      'averageClarityScore': averageClarityScore,
      'dominantEmotions': dominantEmotions,
      'overallFeedback': overallFeedback,
      'suggestionsForImprovement': suggestionsForImprovement,
    };
  }
}
