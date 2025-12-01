// lib/screens/settings/feedback_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; // NEW: Import for Clipboard

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/custom_button.dart';
import '../../core/utils/helpers.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../providers/auth_provider.dart';

class FeedbackScreen extends StatefulWidget {
  static const String routeName = '/feedback';

  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSending = false;
  int _selectedRating = 0; // New state variable for star rating

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _handleSendFeedback() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedRating == 0) {
        Helpers.showSnackbar(context, 'Please provide a star rating.', backgroundColor: AppColors.warning);
        return;
      }

      setState(() {
        _isSending = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userEmail = authProvider.loggedInUser?.email ?? 'anonymous';
      final feedbackMessage = _feedbackController.text.trim();

      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: AppConstants.adminEmail,
        queryParameters: {
          'subject': 'InterviewAce Feedback from $userEmail (Rating: $_selectedRating/5)',
          'body': feedbackMessage,
        },
      );

      try {
        if (await canLaunchUrl(emailLaunchUri)) {
          await launchUrl(emailLaunchUri);
          Helpers.showSnackbar(context, 'Thank you for your feedback! Opening email client.', backgroundColor: AppColors.success);
          _feedbackController.clear();
          setState(() {
            _selectedRating = 0;
          });
        } else {
          // If the email client cannot be opened, show an alert dialog.
          _showEmailFallbackDialog(context);
        }
      } catch (e) {
        Helpers.showSnackbar(context, 'An error occurred. Failed to send feedback.', backgroundColor: AppColors.error);
      } finally {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  // New method to show a dialog when the email client fails to open.
  void _showEmailFallbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundDark.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            side: BorderSide(color: AppColors.primaryLight.withOpacity(0.2)),
          ),
          title: Text(
            'Cannot Open Email Client',
            style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimaryDark),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please manually send your feedback to our support team.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Text(
                AppConstants.adminEmail,
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryLight, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Close',
                style: AppTextStyles.buttonText.copyWith(color: AppColors.textSecondaryDark),
              ),
            ),
            CustomButton(
              text: 'Copy Email',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: AppConstants.adminEmail));
                Helpers.showSnackbar(context, 'Email address copied!', backgroundColor: AppColors.info);
                Navigator.of(dialogContext).pop();
              },
              isSecondary: true,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
                textStyle: AppTextStyles.buttonText.copyWith(fontSize: 14),
              ),
            ),
          ],
        );
      },
    );
  }

  // New widget to build the star rating row
  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return IconButton(
          icon: Icon(
            starIndex <= _selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
            color: starIndex <= _selectedRating ? AppColors.warning : AppColors.textSecondaryDark,
            size: AppConstants.iconSizeLarge * 1.2,
          ),
          onPressed: () {
            setState(() {
              _selectedRating = starIndex;
            });
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          'Feedback',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimaryDark),
        ),
        backgroundColor: AppColors.backgroundDark.withOpacity(0.5),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(color: Colors.transparent),
          ),
        ),
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
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: AppTheme.applyGlassmorphism(
                blurX: 10.0, blurY: 10.0, opacity: 0.15,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingExtraLarge),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Send us Your Feedback',
                          style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimaryDark),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        Text(
                          'Help us improve by rating your experience and sharing your thoughts below.',
                          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondaryDark),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.paddingLarge),

                        Text(
                          'Your Rating:',
                          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryDark),
                          textAlign: TextAlign.center,
                        ),
                        _buildStarRating(),
                        const SizedBox(height: AppConstants.paddingLarge),

                        CustomTextField(
                          labelText: 'Suggestions',
                          hintText: 'Enter your suggestions here...',
                          controller: _feedbackController,
                          maxLines: 5,
                          keyboardType: TextInputType.multiline,
                          validator: (value) => value!.isEmpty ? 'Suggestions cannot be empty.' : null,
                        ),
                        const SizedBox(height: AppConstants.paddingLarge),
                        CustomButton(
                          text: 'SUBMIT FEEDBACK',
                          onPressed: _isSending ? null : _handleSendFeedback,
                          isLoading: _isSending,
                          icon: const Icon(Icons.send_outlined, color: AppColors.backgroundDark),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
