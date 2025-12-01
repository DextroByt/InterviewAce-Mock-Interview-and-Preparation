// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // For ImageFilter.blur
import 'dart:math'; // For random tip selection
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:io';


import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../models/interview_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../providers/interview_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/custom_button.dart';


import '../interview/interview_setup_screen.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';
import '../report/interview_report_screen.dart';
import '../prepare/prepare_screen.dart';

// This screen serves as the main dashboard for the user after authentication,
// featuring an advanced UI with glassmorphism, animations, and a bottom navigation.
// The UI is now permanently set to dark mode aesthetics.

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedIndex = 0; // Current selected tab index

  final List<String> _dailyTips = [
    "For behavioral questions, use the STAR method: Situation, Task, Action, Result.",
    "Research the company's latest news and mention it during your interview.",
    "Prepare at least three thoughtful questions to ask your interviewer.",
    "Your body language speaks volumes. Sit upright, maintain eye contact, and smile.",
    "End the interview on a high note by reiterating your interest in the role.",
    "Practice, practice, practice. The more you rehearse, the more confident you'll be.",
    "Listen carefully to the question before formulating your answer. Don't rush.",
    "Quantify your achievements whenever possible. Numbers are powerful.",
    "Get a good night's sleep before the interview. A rested mind is a sharp mind."
  ];

  String _currentDailyTip = "";
  // NEW: Added a list of student reviews
  final List<Map<String, String>> _studentReviews = [
    {'name': 'Aashish Gupta', 'review': 'The AI feedback is incredibly accurate and insightful. It helped me identify and fix my weak points in no time.'},
    {'name': 'Ritik Vimal Prasad', 'review': 'I love the customizable interviews! It felt like I was talking to a real person, and my confidence has soared.'},
    {'name': 'Suyash Salaskar', 'review': 'The Learn Hub is a goldmine of information. I aced my quiz and felt fully prepared for my real interview.'},
    {'name': 'Ajay Prajapati', 'review': 'This app is a game-changer. The detailed reports are fantastic, and the daily tips are a great way to stay motivated.'},
    {'name': 'Simran', 'review': 'I was nervous about my first big interview, but after using InterviewAce, I felt calm and ready. The practice sessions made all the difference!'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
        Provider.of<UserProfileProvider>(context, listen: false).fetchUserProfile(context);
        Provider.of<InterviewProvider>(context, listen: false).fetchInterviewHistory(context);
        _setDailyTip();
      }
    });
  }

  void _setDailyTip() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    setState(() {
      _currentDailyTip = _dailyTips[dayOfYear % _dailyTips.length];
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
      // Already on Home
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed(HistoryScreen.routeName);
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed(InterviewSetupScreen.routeName);
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed(SettingsScreen.routeName);
        break;
    }
  }

  // Helper function to get the color for a given badge
  Color _getBadgeColor(String badge) {
    switch (badge) {
      case 'Gold':
        return Colors.amber;
      case 'Silver':
        return Colors.blueGrey.shade300;
      case 'Bronze':
        return Colors.brown.shade400;
      default:
        return AppColors.textSecondaryDark;
    }
  }

  // UPDATED: Widget to build the Dashboard Card
  Widget _buildDashboardCard(BuildContext context, InterviewProvider interviewProvider) {
    final interviewCount = interviewProvider.interviewHistory.length;
    final averageScore = interviewCount > 0
        ? interviewProvider.interviewHistory.map((e) => e.analysis?.averageClarityScore ?? 0).reduce((a, b) => a + b) / interviewCount
        : 0.0;

    return AppTheme.applyGlassmorphism(
      blurX: 10.0,
      blurY: 10.0,
      opacity: 0.15,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Your Dashboard',
                  style: AppTextStyles.heading3.copyWith(color: AppColors.primaryLight),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed(HistoryScreen.routeName),
                  child: Text(
                    'View All',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondaryLight),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Divider(color: AppColors.textSecondaryDark.withOpacity(0.3), thickness: 1),
            const SizedBox(height: AppConstants.paddingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDashboardMetric(
                  context,
                  title: 'Interviews',
                  value: interviewCount.toString(),
                  icon: Icons.mic_none_outlined,
                  color: AppColors.info,
                ),
                _buildDashboardMetric(
                  context,
                  title: 'Avg. Score',
                  value: '${(averageScore * 100).toStringAsFixed(0)}%',
                  icon: Icons.trending_up_outlined,
                  color: AppColors.success,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardMetric(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: AppConstants.iconSizeMedium),
            const SizedBox(width: AppConstants.paddingSmall),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingSmall / 2),
        Text(
          value,
          style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimaryDark),
        ),
      ],
    );
  }

  // UPDATED: Redesigned Learn Hub and Quiz Section.
  Widget _buildNewLearnHubCard(BuildContext context, UserProfileProvider userProfileProvider) {
    final quizBadge = userProfileProvider.userProfile?.quizBadge ?? 'None';
    final badgeColor = _getBadgeColor(quizBadge);

    return AppTheme.applyGlassmorphism(
      blurX: 10.0,
      blurY: 10.0,
      opacity: 0.15,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(PrepareScreen.routeName),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingExtraLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Learn Hub & Quiz',
                          style: AppTextStyles.heading2.copyWith(color: AppColors.primaryLight),
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Text(
                          'Improve your knowledge with quizzes and solutions.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.school_outlined, color: AppColors.secondaryLight, size: AppConstants.iconSizeLarge * 1.5),
                ],
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Your Badge: ',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                      ),
                      Chip(
                        label: Text(
                          quizBadge,
                          style: AppTextStyles.buttonText.copyWith(color: AppColors.backgroundDark),
                        ),
                        backgroundColor: badgeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                          side: BorderSide.none,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios, color: AppColors.textSecondaryDark.withOpacity(0.6), size: AppConstants.iconSizeSmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // NEW: Widget for student reviews section
  Widget _buildStudentReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
          child: Text(
            'Student Reviews',
            style: AppTextStyles.heading2.copyWith(color: AppColors.primaryLight),
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        SizedBox(
          height: 150, // Fixed height for the horizontal list
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingSmall),
            itemCount: _studentReviews.length,
            itemBuilder: (context, index) {
              final review = _studentReviews[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingSmall),
                child: _buildReviewCard(review),
              );
            },
          ),
        ),
      ],
    );
  }

  // NEW: Widget to build a single review card
  Widget _buildReviewCard(Map<String, String> review) {
    return AppTheme.applyGlassmorphism(
      blurX: 8.0,
      blurY: 8.0,
      opacity: 0.1,
      child: Container(
        width: 250, // Fixed width for each card
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_pin_circle_outlined, color: AppColors.primaryLight),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  review['name']!,
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Expanded(
              child: Text(
                review['review']!,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark, fontStyle: FontStyle.italic),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(UserProfileProvider userProfileProvider) {
    final String? profilePicturePath = userProfileProvider.userProfile?.profilePicturePath;
    final bool hasProfilePicture = profilePicturePath != null && File(profilePicturePath).existsSync();

    ImageProvider? backgroundImage;
    if (hasProfilePicture) {
      backgroundImage = FileImage(File(profilePicturePath));
    } else {
      backgroundImage = null; // Use placeholder icon
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.surfaceDark,
              backgroundImage: backgroundImage,
              child: !hasProfilePicture
                  ? const Icon(Icons.person_outline, color: AppColors.textSecondaryDark)
                  : null,
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                  ),
                  Text(
                    userProfileProvider.userProfile?.displayName ?? 'User',
                    style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimaryDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainActionCard(BuildContext context) {
    return AppTheme.applyGlassmorphism(
      blurX: 10.0,
      blurY: 10.0,
      opacity: 0.2,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(InterviewSetupScreen.routeName),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Row(
            children: [
              Icon(Icons.mic_none_outlined, color: AppColors.primaryLight, size: AppConstants.iconSizeLarge * 1.5),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start New Interview',
                      style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimaryDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Get instant AI feedback and analysis',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondaryDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyTipCard() {
    return AppTheme.applyGlassmorphism(
      blurX: 10.0,
      blurY: 10.0,
      opacity: 0.15,
      overlayColor: AppColors.secondary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Row(
          children: [
            const Icon(Icons.campaign_outlined, color: AppColors.secondaryLight, size: AppConstants.iconSizeLarge),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Today's Tip", style: AppTextStyles.buttonText.copyWith(color: AppColors.secondaryLight)),
                  Text(
                    _currentDailyTip,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.borderRadiusLarge)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: BottomNavigationBar(
          backgroundColor: AppColors.surfaceDark.withOpacity(0.2),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: AppColors.primaryLight,
          unselectedItemColor: AppColors.textSecondaryDark.withOpacity(0.7),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
          unselectedLabelStyle: AppTextStyles.caption,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.history_outlined), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.mic_none), label: 'Interview'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final interviewProvider = Provider.of<InterviewProvider>(context);

    if (userProfileProvider.userProfile == null && authProvider.isAuthenticated) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: LoadingWidget(isFullScreen: true, message: 'Loading your dashboard...'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
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
                ),
              ),
            ),
          ),
          SafeArea(
            child: AnimationLimiter(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: AppConstants.paddingMedium),
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
                  children: [
                    _buildModernHeader(userProfileProvider),
                    const SizedBox(height: AppConstants.paddingMedium),
                    _buildMainActionCard(context),
                    const SizedBox(height: AppConstants.paddingMedium),
                    _buildDailyTipCard(),
                    const SizedBox(height: AppConstants.paddingExtraLarge),
                    _buildDashboardCard(context, interviewProvider),
                    const SizedBox(height: AppConstants.paddingMedium),
                    _buildNewLearnHubCard(context, userProfileProvider),
                    const SizedBox(height: AppConstants.paddingExtraLarge),
                    _buildStudentReviewsSection(),
                    const SizedBox(height: AppConstants.paddingExtraLarge),
                    // --- Developer Credit ---
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Developed By Dextrobyt',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondaryDark.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 80), // Space for bottom nav bar
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
