// lib/services/free_ai_service.dart


import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:math';


import '../core/services/api_service.dart';
import '../core/constants/app_constants.dart';
import '../models/question_model.dart';
import '../models/interview_model.dart';


// This service interacts with the Google Gemini API to:
// 1. Generate a personalized greeting.
// 2. Generate interview questions based on specified job role and difficulty.
// 3. Generate feedback for user responses during an interview.
// 4. Generate overall interview feedback and suggestions.
// 5. NEW: Generate solutions for interview questions.
// 6. NEW: Generate multiple-choice quiz options.


class FreeAiService {
  final ApiService _apiService;
  final String _geminiModel = AppConstants.geminiModel;
  final String _geminiApiKey = AppConstants.geminiApiKey;


  FreeAiService({required ApiService apiService}) : _apiService = apiService;


  Future<Map<String, dynamic>> _callGeminiApi(List<Map<String, dynamic>> contents, {Map<String, dynamic>? generationConfig}) async {
    final String path = '$_geminiModel:generateContent?key=$_geminiApiKey';
    final Map<String, dynamic> payload = {'contents': contents};
    if (generationConfig != null) {
      payload['generationConfig'] = generationConfig;
    }
    try {
      final response = await _apiService.post(path, body: payload);
      if (response['candidates'] != null &&
          response['candidates'].isNotEmpty &&
          response['candidates'][0]['content'] != null &&
          response['candidates'][0]['content']['parts'] != null &&
          response['candidates'][0]['content']['parts'].isNotEmpty &&
          response['candidates'][0]['content']['parts'][0]['text'] != null) {
        return {'text': response['candidates'][0]['content']['parts'][0]['text']};
      } else {
        debugPrint('Unexpected Gemini API response structure: $response');
        throw ApiException('Failed to get valid response from AI. Unexpected structure.');
      }
    } on ApiException catch (e) {
      debugPrint('Gemini API Error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error calling Gemini API: $e');
      throw ApiException('Failed to communicate with AI service: $e');
    }
  }


  Future<String> generateGreeting({required String userName, required String jobRole}) async {
    debugPrint('Requesting a greeting for $userName for the $jobRole role...');
    final String prompt = '''
    You are an AI interviewer. Generate a warm, professional, and brief opening greeting for a mock interview.
    The candidate's name is "$userName".
    The interview is for a "$jobRole" position.
    Keep it to one or two short sentences. Start with a greeting like "Hello, $userName" or "Welcome, $userName".
    Example: "Welcome, $userName. Thanks for coming in today. Let's get started with your interview for the $jobRole position."
    ''';


    final List<Map<String, dynamic>> contents = [{'role': 'user', 'parts': [{'text': prompt}]}];


    try {
      final response = await _callGeminiApi(contents);
      return response['text'].replaceAll('"', '').trim();
    } catch (e) {
      debugPrint('Error generating greeting: $e');
      return "Hello, $userName. Welcome to your mock interview for the $jobRole position. Let's begin.";
    }
  }


  Future<List<QuestionModel>> generateInterviewQuestions({
    required String jobRole,
    required String difficulty,
    required int count,
  }) async {
    debugPrint('Requesting $count $difficulty questions for job role: $jobRole...');
    String prompt = '''
    Generate $count interview questions for a candidate applying for a "$jobRole" position.
    The questions should be of "$difficulty" difficulty.
    Ensure the questions are highly relevant, distinct, and directly applicable to the specified job role.
    Provide the questions in a JSON array format, where each object has 'id', 'text', 'category', and 'difficulty'.
    Example format:
    [
      {"id": "q1", "text": "Question 1 text here.", "category": "Behavioral", "difficulty": "Medium"},
      {"id": "q2", "text": "Question 2 text here.", "category": "Technical", "difficulty": "Medium"}
    ]
    ''';


    final List<Map<String, dynamic>> contents = [{'role': 'user', 'parts': [{'text': prompt}]}];
    final Map<String, dynamic> generationConfig = {
      'responseMimeType': 'application/json',
      'responseSchema': {
        'type': 'ARRAY',
        'items': {
          'type': 'OBJECT',
          'properties': {
            'id': {'type': 'STRING'},
            'text': {'type': 'STRING'},
            'category': {'type': 'STRING'},
            'difficulty': {'type': 'STRING'},
          },
          'required': ['id', 'text', 'category', 'difficulty']
        }
      }
    };


    try {
      final response = await _callGeminiApi(contents, generationConfig: generationConfig);
      final String jsonString = response['text'];
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => QuestionModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error generating interview questions: $e');
      throw AiServiceException('Failed to generate questions. Please try again later.');
    }
  }


  Future<String> generateQuestionFeedback({
    required String question,
    required String userResponse,
    required Map<String, dynamic> analysis,
    required Map<String, double> emotionData,
  }) async {
    final String prompt = '''
    You are an AI interview coach. Provide concise and constructive feedback for the following user's response to an interview question.
    Consider the question, the user's response, and the provided analysis data.
    
    Question: "$question"
    User's Response: "$userResponse"
    
    Speech Analysis:
    - Speaking Rate (WPM): ${analysis['speakingRateWPM']}
    - Filler Word Count: ${analysis['fillerWordCount']}
    - Clarity Score (0-1): ${analysis['clarityScore']}
    
    Emotion Detected (dominant emotions and their scores): ${emotionData.entries.map((e) => '${e.key}: ${(e.value * 100).toStringAsFixed(0)}%').join(', ')}
    
    Provide feedback focusing on:
    1. Content relevance and completeness.
    2. Clarity and conciseness.
    3. Delivery (speaking rate, filler words, confidence implied by emotions).
    
    Keep the feedback to 2-3 concise sentences.
    ''';


    final List<Map<String, dynamic>> contents = [{'role': 'user', 'parts': [{'text': prompt}]}];


    try {
      final response = await _callGeminiApi(contents);
      return response['text'];
    } catch (e) {
      debugPrint('Error generating question feedback: $e');
      throw AiServiceException('Failed to generate feedback. Please try again.');
    }
  }


  // NEW: Method to generate a solution for a given interview question.
  Future<String> generateQuestionSolution({required String question}) async {
    debugPrint('Requesting solution for question: "$question"');
    final String prompt = '''
    You are an expert in interview preparation. Provide a concise, helpful solution to the following interview question.
    Answer in a natural, conversational tone, as if you were a mentor explaining the concept to a junior colleague.
    Structure the response as one or two concise paragraphs.
    Focus on key concepts and best practices, and explain them simply.
    Do not use or refer to any technical diagrams, graphs, or code structures.
    
    Question: "$question"
    ''';


    final List<Map<String, dynamic>> contents = [{'role': 'user', 'parts': [{'text': prompt}]}];


    try {
      final response = await _callGeminiApi(contents);
      return response['text'];
    } catch (e) {
      debugPrint('Error generating question solution: $e');
      throw AiServiceException('Failed to generate solution. Please try again later.');
    }
  }

  // NEW: Method to generate a list of quiz options (including a correct answer and incorrect ones).
  Future<List<String>> generateQuizOptions({
    required String question,
    required String correctAnswer,
  }) async {
    debugPrint('Requesting quiz options for question: "$question"');
    final String prompt = '''
    You are an expert in creating multiple-choice quiz questions.
    For the following question and its correct answer, generate 3 plausible but incorrect multiple-choice options.
    Ensure the incorrect options are related to the topic but are definitively wrong.
    Do not include the correct answer in your response.
    Provide the 3 incorrect options in a JSON array of strings.
    Example JSON format:
    ["Incorrect Option 1", "Incorrect Option 2", "Incorrect Option 3"]
    
    Question: "$question"
    Correct Answer: "$correctAnswer"
    ''';


    final List<Map<String, dynamic>> contents = [{'role': 'user', 'parts': [{'text': prompt}]}];
    final Map<String, dynamic> generationConfig = {
      'responseMimeType': 'application/json',
      'responseSchema': {
        'type': 'ARRAY',
        'items': {'type': 'STRING'},
      }
    };


    try {
      final response = await _callGeminiApi(contents, generationConfig: generationConfig);
      final String jsonString = response['text'];
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<String> incorrectOptions = jsonList.map((e) => e.toString()).toList();


      // Combine the correct answer with the incorrect options and shuffle them.
      final allOptions = [...incorrectOptions, correctAnswer];
      allOptions.shuffle(Random()); // Use dart:math's Random for shuffling
      return allOptions;
    } catch (e) {
      debugPrint('Error generating quiz options: $e');
      // Fallback in case of API failure
      return [correctAnswer, 'A different incorrect answer.', 'Another incorrect option.', 'Yet another incorrect choice.'];
    }
  }


  Future<Map<String, dynamic>> generateOverallInterviewFeedback({
    required double overallSpeakingRateWPM,
    required int totalFillerWordCount,
    required double averageClarityScore,
    required InterviewConfig interviewConfig,
    required List<QuestionAnswer> questionsAndAnswers,
  }) async {
    String prompt = '''
    You are an AI interview coach and mentor. Provide a comprehensive, precise, and truly useful overall feedback for an interview session.
    Also, provide a list of actionable suggestions for improvement.
    
    Interview Configuration:
    - Job Role: ${interviewConfig.jobRole}
    - Difficulty: ${interviewConfig.difficulty}
    
    Overall Performance Metrics:
    - Average Speaking Rate: ${overallSpeakingRateWPM.toStringAsFixed(1)} WPM
    - Total Filler Words: $totalFillerWordCount
    - Average Clarity Score: ${(averageClarityScore * 100).toStringAsFixed(0)}%
    
    Detailed Questions and User Responses:
    ''';


    for (int i = 0; i < questionsAndAnswers.length; i++) {
      final qa = questionsAndAnswers[i];
      prompt += '''
    - Question ${i + 1}: "${qa.questionText}"
      User's Response: "${qa.userResponse}"
      ''';
      if (qa.analysis != null) {
        prompt += '''
      (Speech Analysis: WPM: ${qa.analysis!.speakingRateWPM.toStringAsFixed(1)}, Fillers: ${qa.analysis!.fillerWordCount}, Clarity: ${(qa.analysis!.clarityScore * 100).toStringAsFixed(0)}%)
      (Individual Feedback: ${qa.analysis!.feedback})
      ''';
      }
    }


    prompt += '''
    
    Based on the above data, provide:
    1.  **Overall Feedback**: A concise, professional, and encouraging summary of the candidate's performance.
    2.  **Suggestions for Improvement**: A list of 3-5 specific, actionable steps the candidate can take to improve.


    Provide the output in a JSON object with two keys: "overallFeedback" (string) and "suggestions" (array of strings).
    Example JSON format:
    {
      "overallFeedback": "Your overall performance was strong...",
      "suggestions": ["Practice using the STAR method..."]
    }
    ''';


    final List<Map<String, dynamic>> contents = [{'role': 'user', 'parts': [{'text': prompt}]}];
    final Map<String, dynamic> generationConfig = {
      'responseMimeType': 'application/json',
      'responseSchema': {
        'type': 'OBJECT',
        'properties': {
          'overallFeedback': {'type': 'STRING'},
          'suggestions': {'type': 'ARRAY', 'items': {'type': 'STRING'}},
        },
        'required': ['overallFeedback', 'suggestions']
      }
    };


    try {
      final response = await _callGeminiApi(contents, generationConfig: generationConfig);
      final String jsonString = response['text'];
      return jsonDecode(jsonString);
    } catch (e) {
      debugPrint('Error generating overall interview feedback: $e');
      throw AiServiceException('Failed to generate overall report. Please try again.');
    }
  }
}


class AiServiceException implements Exception {
  final String message;
  AiServiceException(this.message);


  @override
  String toString() => 'AiServiceException: $message';
}
