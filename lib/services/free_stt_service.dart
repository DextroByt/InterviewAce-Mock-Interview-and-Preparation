// lib/services/free_stt_service.dart

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:permission_handler/permission_handler.dart'; // Import for permission_handler
import 'dart:async';

class FreeSpeechToText {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  final StreamController<String> _speechRecognitionController = StreamController<String>.broadcast();
  Stream<String> get speechRecognitionStream => _speechRecognitionController.stream;

  bool get isSpeechEnabled => _speechEnabled;

  Future<void> initSTT() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onStatus: _onStatus,
        onError: _onError,
        debugLogging: true,
      );
      if (_speechEnabled) {
        debugPrint('Speech-to-Text initialized successfully.');
      } else {
        debugPrint('Speech-to-Text initialization failed. Microphone access denied or not available.');
      }
    } catch (e) {
      debugPrint('Error initializing Speech-to-Text: $e');
      _speechEnabled = false;
    }
  }

  // New method to check and request microphone permission
  Future<bool> checkPermission() async {
    PermissionStatus status = await Permission.microphone.status;
    if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

  Future<bool> startListening() async {
    if (_speechEnabled && !_speechToText.isListening) {
      _lastWords = '';
      _speechRecognitionController.add('');
      try {
        await _speechToText.listen(
          onResult: _onSpeechResult,
          // MODIFIED: Set listenFor to 60 minutes to ensure continuous listening
          listenFor: const Duration(minutes: 60),
          // MODIFIED: Set pauseFor to 60 minutes to prevent stopping on silence
          pauseFor: const Duration(minutes: 60),
          localeId: 'en_US',
          cancelOnError: true,
          partialResults: true,
        );
        debugPrint('Started listening...');
        return true;
      } catch (e) {
        debugPrint('Error starting listening: $e');
        _speechRecognitionController.addError('Failed to start listening: $e');
        return false;
      }
    } else {
      debugPrint('Cannot start listening. Details: speechEnabled=$_speechEnabled, isListening=${_speechToText.isListening}');
      return false;
    }
  }

  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
      debugPrint('Stopped listening.');
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastWords = result.recognizedWords;
    _speechRecognitionController.add(_lastWords);
    debugPrint('Recognized: "$_lastWords" (final: ${result.finalResult})');
  }

  void _onStatus(String status) {
    debugPrint('Speech-to-Text Status: $status');
  }

  void _onError(SpeechRecognitionError error) {
    debugPrint('Speech-to-Text Error: ${error.errorMsg} - permanent: ${error.permanent}');
    _speechRecognitionController.addError('Speech recognition error: ${error.errorMsg}');

    // FIX: Do not permanently disable the service on a "no match" error.
    // Some devices report this as a permanent error, but we want to be able to try again.
    if (error.permanent && error.errorMsg != 'error_no_match') {
      _speechEnabled = false;
    }
  }

  void dispose() {
    _speechToText.cancel();
    _speechRecognitionController.close();
    debugPrint('Speech-to-Text service disposed.');
  }
}
