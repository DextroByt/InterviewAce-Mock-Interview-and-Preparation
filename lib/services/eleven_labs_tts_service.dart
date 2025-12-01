// lib/services/eleven_labs_tts_service.dart

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import '../core/constants/app_constants.dart';

// This service handles all interactions with the ElevenLabs Text-to-Speech API.
// It converts text to high-quality spoken audio and plays it.
class ElevenLabsTtsService {
  final String _apiKey = AppConstants.elevenLabsApiKey;
  final String _apiBaseUrl = 'https://api.elevenlabs.io/v1/text-to-speech';

  final AudioPlayer _audioPlayer = AudioPlayer();
  final StreamController<bool> _isSpeakingController = StreamController<bool>.broadcast();
  Stream<bool> get isSpeakingStream => _isSpeakingController.stream;

  ElevenLabsTtsService() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        _isSpeakingController.add(true);
        debugPrint('ElevenLabs TTS: Speaking started');
      } else if (state == PlayerState.completed || state == PlayerState.stopped) {
        _isSpeakingController.add(false);
        debugPrint('ElevenLabs TTS: Speaking finished');
      }
    });
  }

  // Speaks the given text using a specified gender's voice from ElevenLabs.
  Future<void> speak(String text, {required String gender}) async {
    if (_apiKey.isEmpty || _apiKey == "YOUR_ELEVENLABS_API_KEY_HERE") {
      debugPrint('ElevenLabs API key is not set. Cannot speak.');
      // Optionally, you could fall back to the old TTS service here.
      return;
    }
    if (text.isEmpty) {
      debugPrint('No text to speak.');
      return;
    }

    // Stop any currently playing audio
    await stop();

    // Select the voice ID based on gender
    final voiceId = gender.toLowerCase() == 'male'
        ? AppConstants.elevenLabsMaleVoiceId
        : AppConstants.elevenLabsFemaleVoiceId;

    final url = '$_apiBaseUrl/$voiceId';

    try {
      debugPrint('Requesting speech from ElevenLabs for voice: $voiceId');
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'xi-api-key': _apiKey,
        },
        body: '{"text": "$text", "model_id": "eleven_multilingual_v2", "voice_settings": {"stability": 0.5, "similarity_boost": 0.75}}',
      );

      if (response.statusCode == 200) {
        final Uint8List audioBytes = response.bodyBytes;
        await _audioPlayer.play(BytesSource(audioBytes));
      } else {
        debugPrint('ElevenLabs API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to get audio from ElevenLabs.');
      }
    } catch (e) {
      debugPrint('Error in speak method: $e');
      _isSpeakingController.add(false); // Ensure state is reset on error
      rethrow;
    }
  }

  // Stops any ongoing speech.
  Future<void> stop() async {
    if (_audioPlayer.state == PlayerState.playing) {
      await _audioPlayer.stop();
      debugPrint('ElevenLabs TTS: Speaking stopped by user.');
    }
  }

  // Disposes the resources used by the service.
  void dispose() {
    _audioPlayer.dispose();
    _isSpeakingController.close();
    debugPrint('ElevenLabsTtsService disposed.');
  }
}
