// lib/screens/interview/interview_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'package:camera/camera.dart'; // Import for camera access


import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/helpers.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/interview_provider.dart';
import '../../services/free_stt_service.dart';
import '../../services/eleven_labs_tts_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/ai_character.dart';


import '../report/interview_report_screen.dart';


class InterviewScreen extends StatefulWidget {
  static const String routeName = '/interview';


  const InterviewScreen({super.key});


  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}


class _InterviewScreenState extends State<InterviewScreen> {
  late ElevenLabsTtsService _ttsService;
  late FreeSpeechToText _sttService;


  StreamSubscription? _ttsSubscription;
  StreamSubscription? _sttSubscription;
  CameraController? _cameraController;


  String _currentSpeechText = '';
  String _displayText = 'Preparing interview...';
  bool _isListening = false;
  bool _isAiSpeaking = false;
  bool _isProcessingInput = false;
  bool _isInterviewEnding = false;
  bool _isCameraOn = false; // User camera is off by default
  Timer? _questionTimer;
  int _secondsElapsed = 0;

  // New state variables for video swap
  bool _isInterviewerFullScreen = true;

  // New state variable for the touch-to-speak button functionality
  bool _isMicActive = false;


  @override
  void initState() {
    super.initState();


    _ttsService = Provider.of<ElevenLabsTtsService>(context, listen: false);
    _sttService = Provider.of<FreeSpeechToText>(context, listen: false);


    _ttsSubscription = _ttsService.isSpeakingStream.listen((isSpeaking) {
      if (mounted) {
        setState(() => _isAiSpeaking = isSpeaking);
        if (!isSpeaking) {
          _handleTtsCompletion();
        }
      }
    });


    _sttSubscription = _sttService.speechRecognitionStream.listen(
            (text) {
          if (mounted) {
            setState(() {
              _currentSpeechText = text;
              _displayText = text;
            });
          }
        },
        onError: (error) {
          debugPrint("STT Stream Error: $error");
          if (mounted) {
            setState(() => _isListening = false);
            Helpers.showSnackbar(context, "Speech recognition error. Please try again.", backgroundColor: AppColors.error);
          }
        }
    );


    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCamera();
      _startInterviewFlow();
    });
  }


  @override
  void dispose() {
    _ttsSubscription?.cancel();
    _sttSubscription?.cancel();
    _ttsService.stop();
    _questionTimer?.cancel();
    _sttService.stopListening();
    _cameraController?.dispose();
    super.dispose();
  }


  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(
        cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front,
            orElse: () => cameras.first),
        ResolutionPreset.medium,
      );
      try {
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {});
        }
      } on CameraException catch (e) {
        debugPrint("Camera initialization error: $e");
        Helpers.showSnackbar(context, "Failed to access camera: ${e.description}", backgroundColor: AppColors.error);
      }
    }
  }


  void _toggleCamera() {
    setState(() {
      _isCameraOn = !_isCameraOn;
    });
    if (_cameraController != null) {
      if (_isCameraOn) {
        _cameraController!.resumePreview();
      } else {
        _cameraController!.pausePreview();
      }
    }
  }

  // Toggles the full-screen view between the AI interviewer and the user's camera.
  void _toggleFullScreenView() {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      setState(() {
        _isInterviewerFullScreen = !_isInterviewerFullScreen;
      });
    }
  }


  void _startInterviewFlow() {
    final interviewProvider = Provider.of<InterviewProvider>(context, listen: false);
    final greeting = interviewProvider.greetingMessage;


    if (greeting != null) {
      setState(() => _displayText = greeting);
      _speakText(greeting);
    } else {
      _askNextQuestion();
    }
  }


  void _handleTtsCompletion() {
    final interviewProvider = Provider.of<InterviewProvider>(context, listen: false);
    if (interviewProvider.currentQuestionNumber == 0) {
      _askNextQuestion();
    } else {
      setState(() {
        _displayText = 'Tap to Answer';
      });
    }
  }


  void _askNextQuestion() {
    final interviewProvider = Provider.of<InterviewProvider>(context, listen: false);

    _isProcessingInput = true;
    _currentSpeechText = '';


    if (interviewProvider.nextQuestion()) {
      final currentQuestion = interviewProvider.currentQuestion;
      if (currentQuestion != null) {
        setState(() {
          _displayText = currentQuestion.text;
          _secondsElapsed = 0;
          _isProcessingInput = false;
        });
        _stopQuestionTimer();
        _sttService.stopListening();
        _speakText(currentQuestion.text);
      }
    } else {
      _endInterview();
    }
  }


  Future<void> _speakText(String text) async {
    final interviewProvider = Provider.of<InterviewProvider>(context, listen: false);
    await _ttsService.speak(
      text,
      gender: interviewProvider.currentInterview?.config.aiInterviewerGender ?? 'female',
    );
  }


  Future<void> _startListening() async {
    if (_isAiSpeaking || _isProcessingInput || _isInterviewEnding) {
      return;
    }

    // Check for microphone permission
    if (!await _sttService.checkPermission()) {
      if(mounted) {
        _showPermissionDialog();
      }
      return;
    }

    _currentSpeechText = '';

    final bool success = await _sttService.startListening();


    if (success) {
      if (mounted) {
        setState(() {
          _isListening = true;
          _isMicActive = true;
          _currentSpeechText = '';
          _displayText = 'Listening...';
        });
        _startQuestionTimer();
      }
    } else {
      if(mounted) {
        Helpers.showSnackbar(context, "Speech recognition error. Please try again.", backgroundColor: AppColors.error);
      }
    }
  }


  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark.withOpacity(0.85),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            side: BorderSide(color: AppColors.primaryLight.withOpacity(0.2))
        ),
        title: Text('Microphone Access', style: AppTextStyles.heading3.copyWith(color: AppColors.primaryLight)),
        content: Text(
          'This app needs microphone access to hear your interview responses. Please grant the permission in your device settings.',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: AppTextStyles.buttonText.copyWith(color: AppColors.primaryLight)),
          ),
        ],
      ),
    );
  }


  Future<void> _stopListening() async {
    if (!mounted || !_isListening) return;


    await _sttService.stopListening();
    _stopQuestionTimer();

    if (_currentSpeechText.isNotEmpty) {
      setState(() {
        _isListening = false;
        _isMicActive = false;
        _displayText = _currentSpeechText;
      });
      _submitAnswer();
    } else {
      setState(() {
        _isListening = false;
        _isMicActive = false;
        _displayText = 'Tap to Answer';
      });
    }
  }

  void _onActionButtonPressed() {
    if (_isMicActive) {
      _stopListening();
    } else {
      _startListening();
    }
  }


  Future<void> _submitAnswer() async {
    setState(() {
      _isProcessingInput = true;
      _displayText = 'Analyzing your answer...';
    });


    final interviewProvider = Provider.of<InterviewProvider>(context, listen: false);
    await interviewProvider.submitResponse(_currentSpeechText);


    _askNextQuestion();
  }


  Future<void> _endInterview() async {
    debugPrint('Ending interview...');
    _stopQuestionTimer();
    await _sttService.stopListening();
    await _ttsService.stop();


    if (mounted) {
      setState(() {
        _isInterviewEnding = true;
        _isProcessingInput = true;
        _displayText = 'Interview complete! Generating your report...';
      });
    }


    final interviewProvider = Provider.of<InterviewProvider>(context, listen: false);
    await interviewProvider.endInterview();


    await Future.delayed(const Duration(seconds: 3));


    if(mounted){
      Navigator.of(context).pushReplacementNamed(InterviewReportScreen.routeName);
    }
  }


  void _startQuestionTimer() {
    _questionTimer?.cancel();
    _secondsElapsed = 0;
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _secondsElapsed++);
    });
  }


  void _stopQuestionTimer() {
    _questionTimer?.cancel();
    _questionTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final interviewProvider = Provider.of<InterviewProvider>(context);
    final bool buttonsDisabled = _isAiSpeaking || _isProcessingInput;
    // final bool canHoldToAnswer = !_isAiSpeaking && !_isProcessingInput && _currentSpeechText.isEmpty;
    // final bool isAnswerReady = _currentSpeechText.isNotEmpty && !_isListening && !_isAiSpeaking && !_isProcessingInput;


    if (interviewProvider.isLoadingQuestions || _isInterviewEnding) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: LoadingWidget(
          isFullScreen: true,
          message: _isInterviewEnding ? _displayText : 'Generating your interview...',
        ),
      );
    }

    Color buttonColor;
    String buttonText;
    IconData buttonIcon;

    if (_isAiSpeaking || _isProcessingInput) {
      buttonColor = AppColors.error;
      buttonText = 'Please Wait..';
      buttonIcon = Icons.mic_off;
    } else if (_isMicActive) {
      buttonColor = AppColors.warning;
      buttonText = 'TAP TO STOP';
      buttonIcon = Icons.mic;
    } else {
      buttonColor = AppColors.success;
      buttonText = 'TAP TO ANSWER';
      buttonIcon = Icons.mic_none;
    }


    final aiCharacterGender = interviewProvider.currentInterview?.config.aiInterviewerGender ?? 'female';
    // Removed unused aiAvatarUrl variable
    // final aiAvatarUrl = aiCharacterGender == 'male'
    //     ? 'assets/images/male_interviewer_real2.png'
    //     : 'assets/images/female_interviewer_real2.png';


    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Full-screen view for either AI or user
          GestureDetector(
            onTap: _toggleFullScreenView,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isInterviewerFullScreen
                  ? Container(
                key: const ValueKey<int>(1),
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.backgroundDark,
                      AppColors.primaryDark,
                      AppColors.backgroundDark,
                    ],
                  ),
                ),
                child: Center(
                  child: AiCharacter(
                    isSpeaking: _isAiSpeaking,
                    gender: aiCharacterGender,
                    size: 250,
                    fit: BoxFit.cover,
                    isBackground: false,
                  ),
                ),
              )
                  : SizedBox(
                key: const ValueKey<int>(2),
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: _isCameraOn && _cameraController != null && _cameraController!.value.isInitialized
                        ? CameraPreview(_cameraController!)
                        : Container(
                      color: AppColors.backgroundDark,
                      child: const Center(
                        child: Icon(Icons.videocam_off, color: AppColors.textSecondaryDark, size: 100),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Small pop-up view for the other participant
          Positioned(
            top: MediaQuery.of(context).padding.top + AppConstants.paddingMedium,
            right: AppConstants.paddingMedium,
            child: GestureDetector(
              onTap: _toggleFullScreenView,
              child: AppTheme.applyGlassmorphism(
                blurX: 10.0,
                blurY: 10.0,
                opacity: 0.25,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  child: Container(
                    width: 120,
                    height: 160,
                    color: AppColors.surfaceDark.withOpacity(0.5),
                    child: _isInterviewerFullScreen
                        ? (_isCameraOn && _cameraController != null && _cameraController!.value.isInitialized
                        ? CameraPreview(_cameraController!)
                        : const Center(
                      child: Icon(Icons.person, color: AppColors.textSecondaryDark, size: 60),
                    ))
                        : Center(
                      child: AiCharacter(
                        isSpeaking: _isAiSpeaking,
                        gender: aiCharacterGender,
                        size: 100,
                        isBackground: false,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + AppConstants.paddingMedium),
              const Spacer(flex: 1),
              // Main Display Text Container (Glassmorphism)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                child: AppTheme.applyGlassmorphism(
                  blurX: 8.0, blurY: 8.0, opacity: 0.25,
                  overlayColor: AppColors.backgroundDark,
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Text(
                      _displayText,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w500,
                        fontStyle: (_displayText == 'Tap to Answer' || _displayText == 'Listening...') ? FontStyle.italic : FontStyle.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              // Question Number and Timer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Q ${interviewProvider.currentQuestionNumber > 0 ? interviewProvider.currentQuestionNumber : '-'} / ${interviewProvider.totalQuestions}',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                    ),
                    Text(
                      'Time: ${Helpers.formatDuration(Duration(seconds: _secondsElapsed))}',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              // Bottom Control Bar (Glassmorphism)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.borderRadiusLarge)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    color: AppColors.backgroundDark.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingLarge,
                      vertical: AppConstants.paddingMedium,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Camera Toggle Button
                        IconButton(
                          icon: Icon(
                            _isCameraOn ? Icons.videocam : Icons.videocam_off,
                            color: _isCameraOn ? AppColors.success : AppColors.textSecondaryDark,
                            size: AppConstants.iconSizeLarge,
                          ),
                          onPressed: _toggleCamera,
                          tooltip: _isCameraOn ? 'Turn Camera Off' : 'Turn Camera On',
                        ),
                        // The main action button with merged mic icon and text
                        GestureDetector(
                          onTap: buttonsDisabled ? null : _onActionButtonPressed,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 50,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                              color: buttonColor,
                              boxShadow: [
                                BoxShadow(
                                  color: buttonColor.withOpacity(0.4),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: _isProcessingInput
                                ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.backgroundDark),
                                strokeWidth: 3,
                              ),
                            )
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  buttonIcon,
                                  color: AppColors.backgroundDark,
                                  size: AppConstants.iconSizeMedium,
                                ),
                                const SizedBox(width: AppConstants.paddingSmall),
                                Text(
                                  buttonText,
                                  style: AppTextStyles.buttonText.copyWith(color: AppColors.backgroundDark),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // End Interview Button
                        IconButton(
                          icon: const Icon(
                            Icons.call_end,
                            color: AppColors.error,
                            size: AppConstants.iconSizeLarge,
                          ),
                          onPressed: buttonsDisabled ? null : _endInterview,
                          tooltip: 'End Interview',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
