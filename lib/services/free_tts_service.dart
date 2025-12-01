// lib/services/free_tts_service.dart

import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:flutter_tts/flutter_tts.dart';

// This service handles the conversion of text into spoken audio using
// the device's native text-to-speech capabilities.

class FreeTextToSpeech {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isTtsInitialized = false;

  // Expose the FlutterTts instance directly
  FlutterTts get flutterTts => _flutterTts;

  // Initializes the Text-to-Speech service.
  Future<void> initTTS() async {
    try {
      await _flutterTts.setLanguage('en-US'); // Set default language
      await _flutterTts.setSpeechRate(0.5); // Set speech rate (0.0 to 1.0)
      await _flutterTts.setVolume(1.0); // Set volume (0.0 to 1.0)
      await _flutterTts.setPitch(1.0); // Set pitch (0.5 to 2.0)

      // These handlers are set internally during initTTS
      _flutterTts.setStartHandler(() {
        debugPrint('TTS: Speaking started');
      });

      _flutterTts.setCompletionHandler(() {
        debugPrint('TTS: Speaking completed');
      });

      _flutterTts.setErrorHandler((msg) {
        debugPrint('TTS Error: $msg');
      });

      _isTtsInitialized = true;
      debugPrint('Text-to-Speech initialized successfully.');
    } catch (e) {
      debugPrint('Error initializing Text-to-Speech: $e');
      _isTtsInitialized = false;
    }
  }

  // Speaks the given text.
  Future<void> speak(String text) async {
    if (!_isTtsInitialized) {
      debugPrint('Text-to-Speech not initialized. Cannot speak.');
      return;
    }
    if (text.isEmpty) {
      debugPrint('No text to speak.');
      return;
    }
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Error speaking text: $e');
    }
  }

  // Stops any ongoing speech.
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      debugPrint('TTS: Speaking stopped');
    } catch (e) {
      debugPrint('Error stopping TTS: $e');
    }
  }

  // Method to set the voice based on gender preference
  Future<void> setVoice(String gender) async {
    try {
      List<dynamic> voices = await _flutterTts.getVoices;
      debugPrint('Available TTS Voices: $voices');

      dynamic selectedVoice;
      if (gender.toLowerCase() == 'female') {
        selectedVoice = voices.firstWhere(
              (voice) => voice['name'].toString().toLowerCase().contains('female'),
          orElse: () => null,
        );
      } else { // Default to male or any available if female not found
        selectedVoice = voices.firstWhere(
              (voice) => voice['name'].toString().toLowerCase().contains('male'),
          orElse: () => null,
        );
      }

      if (selectedVoice != null) {
        await _flutterTts.setVoice({'name': selectedVoice['name'], 'locale': selectedVoice['locale']});
        debugPrint('Set TTS voice to: ${selectedVoice['name']}');
      } else {
        debugPrint('No suitable voice found for gender: $gender. Using default.');
      }
    } catch (e) {
      debugPrint('Error setting TTS voice: $e');
    }
  }

  // Expose setStartHandler for external use by providers
  void setStartHandler(VoidCallback handler) {
    _flutterTts.setStartHandler(() => handler());
  }

  // Expose setCompletionHandler for external use by providers
  void setCompletionHandler(VoidCallback handler) {
    _flutterTts.setCompletionHandler(() => handler());
  }

  // Expose setErrorHandler for external use by providers
  void setErrorHandler(void Function(String) handler) {
    _flutterTts.setErrorHandler((msg) => handler(msg));
  }

  // Disposes the resources used by the service.
  void dispose() {
    _flutterTts.stop(); // Stop any ongoing speech
    // No explicit dispose method for FlutterTts, but stopping is good practice.
    debugPrint('Text-to-Speech service disposed.');
  }
}
