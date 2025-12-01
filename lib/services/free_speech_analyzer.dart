// lib/services/free_speech_analyzer.dart

import 'package:flutter/foundation.dart'; // For debugPrint

// This service analyzes transcribed speech to extract metrics such as
// speaking rate (words per minute), filler word count, and clarity score.

class FreeSpeechAnalyzer {
  // A predefined list of common filler words for analysis.
  // This list can be expanded or made configurable.
  static const List<String> _fillerWords = [
    'um', 'uh', 'like', 'you know', 'so', 'basically', 'actually', 'right', 'okay',
    'well', 'hmm', 'ah', 'er', 'kind of', 'sort of'
  ];

  FreeSpeechAnalyzer();

  // Analyzes the given text (transcribed speech) and duration to extract speech metrics.
  // Returns a map containing speaking rate, filler word count, and clarity score.
  Future<Map<String, dynamic>> analyzeSpeech(String transcribedText, Duration responseDuration) async {
    debugPrint('Analyzing speech: "$transcribedText" for duration: ${responseDuration.inSeconds}s');

    // 1. Calculate Speaking Rate (Words Per Minute - WPM)
    final List<String> words = transcribedText.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
    final int wordCount = words.length;
    final double speakingRateWPM;
    if (responseDuration.inSeconds > 0) {
      speakingRateWPM = (wordCount / responseDuration.inSeconds) * 60;
    } else {
      speakingRateWPM = 0.0; // Avoid division by zero if duration is 0
    }

    // 2. Count Filler Words
    int fillerWordCount = 0;
    final String lowerCaseText = transcribedText.toLowerCase();
    for (String filler in _fillerWords) {
      // Simple count for now, could use regex for more robust detection (e.g., whole words only)
      fillerWordCount += RegExp(r'\b' + filler + r'\b').allMatches(lowerCaseText).length;
    }

    // 3. Estimate Clarity Score (Placeholder)
    // This is a highly simplified placeholder. Real clarity analysis would involve:
    // - Advanced NLP for coherence, grammar, vocabulary.
    // - Comparison against ideal responses.
    // - Potentially, acoustic features if audio was directly processed (which it's not here).
    // For now, we'll base it on filler words and word count.
    double clarityScore = 1.0; // Max score
    if (wordCount > 0) {
      // Deduct points for filler words relative to total words
      clarityScore = (wordCount - fillerWordCount) / wordCount;
      // Ensure score is not negative
      if (clarityScore < 0) clarityScore = 0.0;
    } else if (wordCount == 0 && transcribedText.isNotEmpty) {
      // If text exists but no words detected (e.g., only punctuation), clarity is low
      clarityScore = 0.1;
    } else {
      clarityScore = 0.0; // No words, no clarity
    }

    // Further adjustments to clarity score could be made:
    // - If speaking rate is too high or too low, slightly reduce clarity.
    // - If response is very short for a complex question, reduce clarity.
    // - (Advanced) Check for grammatical errors or complex sentence structures.

    debugPrint('Speech Analysis Result: WPM=$speakingRateWPM, Fillers=$fillerWordCount, Clarity=$clarityScore');

    return {
      'speakingRateWPM': speakingRateWPM,
      'fillerWordCount': fillerWordCount,
      'clarityScore': clarityScore,
    };
  }
}

