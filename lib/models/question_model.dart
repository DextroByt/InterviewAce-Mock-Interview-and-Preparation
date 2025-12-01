// lib/models/question_model.dart

import 'package:flutter/foundation.dart'; // For debugPrint

// This file defines the data structure for an interview question.
// It includes properties like the question text, category, and difficulty.

class QuestionModel {
  final String id; // Unique ID for the question
  final String text; // The actual question text
  final String category; // e.g., "Behavioral", "Technical", "Situational"
  final String difficulty; // e.g., "Easy", "Medium", "Hard"

  // Constructor for creating a QuestionModel instance
  QuestionModel({
    required this.id,
    required this.text,
    required this.category,
    required this.difficulty,
  });

  // Factory constructor to create a QuestionModel instance from a JSON map.
  // This is used when fetching questions from an API or a local database.
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    try {
      return QuestionModel(
        id: json['id'] as String,
        text: json['text'] as String,
        category: json['category'] as String,
        difficulty: json['difficulty'] as String,
      );
    } catch (e) {
      debugPrint('Error parsing QuestionModel from JSON: $e, JSON: $json');
      rethrow;
    }
  }

  // Converts the QuestionModel instance into a JSON map for storage or API calls.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'category': category,
      'difficulty': difficulty,
    };
  }

  // Utility method to create a new QuestionModel instance with updated properties.
  QuestionModel copyWith({
    String? id,
    String? text,
    String? category,
    String? difficulty,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      text: text ?? this.text,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  @override
  String toString() {
    return 'QuestionModel(id: $id, text: "$text", category: $category, difficulty: $difficulty)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QuestionModel &&
        other.id == id &&
        other.text == text &&
        other.category == category &&
        other.difficulty == difficulty;
  }

  @override
  int get hashCode {
    return id.hashCode ^ text.hashCode ^ category.hashCode ^ difficulty.hashCode;
  }
}

// Optional: A class to manage a collection of QuestionModel objects.
// This could be used to load, filter, or retrieve questions from a bank.
// class QuestionBank {
//   final List<QuestionModel> questions;

//   QuestionBank({required this.questions});

//   // Example: Filter questions by category
//   List<QuestionModel> filterByCategory(String category) {
//     return questions.where((q) => q.category == category).toList();
//   }

//   // Example: Get a random question of a certain difficulty
//   QuestionModel? getRandomQuestionByDifficulty(String difficulty) {
//     final filtered = questions.where((q) => q.difficulty == difficulty).toList();
//     if (filtered.isEmpty) return null;
//     return filtered[
//         (DateTime.now().microsecondsSinceEpoch % filtered.length).toInt()];
//   }
// }
