// lib/screens/history/history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // For ImageFilter.blur
import 'package:firebase_auth/firebase_auth.dart'; // For getting current user UID

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/helpers.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/interview_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/custom_button.dart';
import '../../models/interview_model.dart';
import '../../services/free_database_service.dart';

import '../report/interview_report_screen.dart';
import '../home/home_screen.dart';
import '../interview/interview_setup_screen.dart';
import '../settings/settings_screen.dart';

// This screen displays a list of all past interview sessions, allowing users
// to review their performance over time, adhering to the Glassmorphism theme.
// The UI is now permanently set to dark mode aesthetics.

class HistoryScreen extends StatefulWidget {
  static const String routeName = '/history';

  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoadingHistory = true;
  List<InterviewModel> _interviewHistory = [];
  final FreeDatabaseService _databaseService = FreeDatabaseService();
  late StorageService _storageService;

  int _selectedIndex = 1; // Set to 1 for History tab

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _storageService = Provider.of<StorageService>(context, listen: false);
      _loadInterviewHistory();
    });
  }

  Future<void> _loadInterviewHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });
    try {
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        debugPrint('User not authenticated. Cannot load interview history.');
        _interviewHistory = [];
        Helpers.showSnackbar(context, 'Please log in to view your interview history.', backgroundColor: AppColors.warning);
        return;
      }

      final List<Map<String, dynamic>> rawHistory = await _databaseService.getInterviewHistory(userId);
      _interviewHistory = rawHistory.map((data) => InterviewModel.fromJson(data)).toList();
      debugPrint('Loaded ${_interviewHistory.length} interview history items from Firestore.');
    } on DatabaseException catch (e) {
      debugPrint('Database error loading interview history: ${e.message}');
      Helpers.showSnackbar(context, 'Failed to load interview history: ${e.message}', backgroundColor: AppColors.error);
      _interviewHistory = [];
    } catch (e) {
      debugPrint('Error loading interview history: $e');
      Helpers.showSnackbar(context, 'An unexpected error occurred while loading history.', backgroundColor: AppColors.error);
      _interviewHistory = [];
    } finally {
      if(mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
      }
    }
  }

  Future<void> _clearAllHistory() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      Helpers.showSnackbar(context, 'Please log in to clear history.', backgroundColor: AppColors.warning);
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundDark.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            side: BorderSide(color: AppColors.primaryLight.withOpacity(0.2)),
          ),
          title: Text(
            'Clear All History?',
            style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimaryDark),
          ),
          content: Text(
            'Are you sure you want to delete all your interview history? This action cannot be undone.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: AppTextStyles.buttonText.copyWith(color: AppColors.textSecondaryDark),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            CustomButton(
              text: 'Clear',
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              isSecondary: true,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
                textStyle: AppTextStyles.buttonText.copyWith(fontSize: 14),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _isLoadingHistory = true;
      });
      try {
        await _databaseService.clearAllInterviewHistory(userId);
        await _storageService.clearInterviewHistory();
        _interviewHistory = [];
        Helpers.showSnackbar(context, 'All interview history cleared!', backgroundColor: AppColors.success);
      } on DatabaseException catch (e) {
        debugPrint('Database error clearing history: ${e.message}');
        Helpers.showSnackbar(context, 'Failed to clear history: ${e.message}', backgroundColor: AppColors.error);
      } catch (e) {
        debugPrint('Error clearing history: $e');
        Helpers.showSnackbar(context, 'An unexpected error occurred while clearing history.', backgroundColor: AppColors.error);
      } finally {
        if(mounted){
          setState(() {
            _isLoadingHistory = false;
          });
        }
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        break;
      case 1:
        _loadInterviewHistory();
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed(InterviewSetupScreen.routeName);
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed(SettingsScreen.routeName);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          'Interview History',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimaryDark),
        ),
        backgroundColor: AppColors.backgroundDark.withOpacity(0.5),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(color: Colors.transparent),
          ),
        ),
        actions: [
          if (_interviewHistory.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: AppConstants.paddingMedium),
              child: CustomButton(
                text: 'Clear All',
                onPressed: _clearAllHistory,
                isOutline: true,
                isSecondary: true,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingSmall, vertical: AppConstants.paddingSmall / 2),
                  textStyle: AppTextStyles.buttonText.copyWith(fontSize: 12),
                  minimumSize: Size.zero,
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error, width: 1),
                ),
              ),
            ),
        ],
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
          if (_isLoadingHistory)
            const LoadingWidget(
              isFullScreen: true,
              message: 'Loading history...',
            )
          else if (_interviewHistory.isEmpty)
            Center(
              child: AppTheme.applyGlassmorphism(
                blurX: 15.0, blurY: 15.0, opacity: 0.1,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'No interview history found.',
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryDark),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      Text(
                        'Start a new interview to see your progress here!',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),
                      CustomButton(
                        text: 'Start New Interview',
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed(InterviewSetupScreen.routeName);
                        },
                        icon: const Icon(Icons.mic, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              itemCount: _interviewHistory.length,
              itemBuilder: (context, index) {
                final interview = _interviewHistory[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                  child: AppTheme.applyGlassmorphism(
                    blurX: 10.0, blurY: 10.0, opacity: 0.15,
                    child: InkWell(
                      onTap: () {
                        Provider.of<InterviewProvider>(context, listen: false).setCurrentInterview(interview);
                        Navigator.of(context).pushNamed(InterviewReportScreen.routeName);
                      },
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.paddingLarge),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${interview.config.jobRole} Interview',
                              style: AppTextStyles.heading3.copyWith(color: AppColors.primaryLight),
                            ),
                            const SizedBox(height: AppConstants.paddingSmall),
                            Text(
                              'Difficulty: ${interview.config.difficulty}',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                            ),
                            Text(
                              'Date: ${Helpers.formatDate(interview.timestamp)}',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                            ),
                            if (interview.analysis != null) ...[
                              const SizedBox(height: AppConstants.paddingSmall),
                              Text(
                                'Overall Score: ${(interview.analysis!.averageClarityScore * 100).toStringAsFixed(0)}%',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textPrimaryDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                            const SizedBox(height: AppConstants.paddingSmall),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: AppColors.textSecondaryDark.withOpacity(0.6),
                                size: AppConstants.iconSizeMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.borderRadiusLarge)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: BottomNavigationBar(
          backgroundColor: AppColors.backgroundDark.withOpacity(0.5),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: AppColors.primaryLight,
          unselectedItemColor: AppColors.textSecondaryDark.withOpacity(0.6),
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
          unselectedLabelStyle: AppTextStyles.caption,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mic),
              label: 'Interview',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
