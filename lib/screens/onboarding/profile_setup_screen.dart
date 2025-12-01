// lib/screens/onboarding/profile_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // For ImageFilter.blur
import 'dart:io'; // For File class
import 'package:image_picker/image_picker.dart'; // For picking images

import '../../core/constants/app_colors.dart'; // Corrected path
import '../../core/constants/app_constants.dart'; // Corrected path
import '../../core/constants/app_text_styles.dart'; // Corrected path
import '../../core/utils/validators.dart'; // Corrected path
import '../../core/utils/helpers.dart'; // Corrected path
import '../../core/theme/app_theme.dart'; // For glassmorphism effect
import '../../providers/user_profile_provider.dart'; // Corrected path
import '../../widgets/common/custom_text_field.dart'; // Corrected path
import '../../widgets/common/custom_button.dart'; // Corrected path
import '../../widgets/common/loading_widget.dart'; // Corrected path

import '../home/home_screen.dart'; // For navigation after profile setup

// This screen guides the user through setting up their initial profile,
// including their display name and career goals, adhering to the Glassmorphism theme.
// The UI has been completely revamped for a professional and unique look.

class ProfileSetupScreen extends StatefulWidget {
  static const String routeName = '/profile-setup';

  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _careerGoalController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> _careerGoals = [];
  bool _isLoading = false;
  File? _pickedImageFile; // New state variable for the picked image file

  @override
  void initState() {
    super.initState();
    // Pre-fill display name if available from AuthProvider or existing profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      if (userProfileProvider.userProfile != null) {
        _displayNameController.text = userProfileProvider.userProfile!.displayName;
        _careerGoals = List.from(userProfileProvider.userProfile!.careerGoals);

        final profilePath = userProfileProvider.userProfile!.profilePicturePath;
        if (profilePath != null && File(profilePath).existsSync()) {
          _pickedImageFile = File(profilePath);
        }

        setState(() {}); // Update UI with pre-filled data
      }
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _careerGoalController.dispose();
    super.dispose();
  }

  // Adds a career goal to the list.
  void _addCareerGoal() {
    final goal = _careerGoalController.text.trim();
    if (goal.isNotEmpty) {
      if (_careerGoals.length < AppConstants.maxCareerGoals) {
        setState(() {
          _careerGoals.add(goal);
          _careerGoalController.clear();
        });
      } else {
        Helpers.showSnackbar(context, 'You can add a maximum of ${AppConstants.maxCareerGoals} career goals.', backgroundColor: AppColors.warning);
      }
    }
  }

  // Removes a career goal from the list.
  void _removeCareerGoal(int index) {
    setState(() {
      _careerGoals.removeAt(index);
    });
  }

  // Handles the image selection from the device gallery.
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImageFile = File(pickedFile.path);
      });
      Helpers.showSnackbar(context, 'Image selected successfully.', backgroundColor: AppColors.success);
    } else {
      Helpers.showSnackbar(context, 'No image selected.', backgroundColor: AppColors.info);
    }
  }

  // Handles the profile setup submission.
  Future<void> _handleProfileSetup() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_displayNameController.text.trim().isEmpty) {
        Helpers.showSnackbar(context, 'Display name cannot be empty.', backgroundColor: AppColors.error);
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      try {
        await userProfileProvider.updateProfile(
          context: context, // Pass the BuildContext here
          displayName: _displayNameController.text.trim(),
          careerGoals: _careerGoals,
          profilePictureFile: _pickedImageFile, // Pass the picked image file
        );
        Helpers.showSnackbar(context, 'Profile updated successfully!', backgroundColor: AppColors.success);
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      } catch (e) {
        Helpers.showSnackbar(context, 'Failed to save profile: $e', backgroundColor: AppColors.error);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context);

    // Determine the profile picture URL to display
    final String? profilePicturePath = userProfileProvider.userProfile?.profilePicturePath;
    final bool hasProfilePicture = profilePicturePath != null && profilePicturePath.isNotEmpty;

    ImageProvider? backgroundImage;
    if (_pickedImageFile != null) {
      backgroundImage = FileImage(_pickedImageFile!);
    } else if (hasProfilePicture) {
      final localFile = File(profilePicturePath);
      if(localFile.existsSync()){
        backgroundImage = FileImage(localFile);
      } else {
        backgroundImage = null;
      }
    } else {
      backgroundImage = null; // Use placeholder icon
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark, // Consistent dark background
      body: Stack(
        children: [
          // Background (Animated Gradient)
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- Header Section ---
                    Text(
                      'Profile Setup', // Changed Heading
                      style: AppTextStyles.heading1.copyWith(
                        color: AppColors.textPrimaryDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      'Personalize your InterviewAce experience. Your profile helps us tailor content and feedback just for you.',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.paddingExtraLarge * 1.5),

                    // --- Profile Picture Section ---
                    AppTheme.applyGlassmorphism(
                      blurX: 15.0, blurY: 15.0, opacity: 0.1,
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.paddingLarge),
                        child: Column(
                          children: [
                            Text(
                              'Profile Picture',
                              style: AppTextStyles.heading3.copyWith(color: AppColors.primaryLight),
                            ),
                            const SizedBox(height: AppConstants.paddingMedium),
                            GestureDetector(
                              onTap: _pickImage, // Tapping the avatar also opens the picker
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: AppColors.surfaceDark.withOpacity(0.5),
                                backgroundImage: backgroundImage,
                                child: (_pickedImageFile == null && !hasProfilePicture)
                                    ? Icon(Icons.person, size: 60, color: AppColors.textSecondaryDark)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingMedium),
                            CustomButton(
                              text: 'CHANGE PICTURE',
                              onPressed: _pickImage,
                              isOutline: true,
                              isSecondary: true,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                                minimumSize: const Size(0, 48),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingExtraLarge),

                    // --- Basic Information Section ---
                    AppTheme.applyGlassmorphism(
                      blurX: 15.0, blurY: 15.0, opacity: 0.1,
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.paddingLarge),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Basic Information',
                              style: AppTextStyles.heading3.copyWith(color: AppColors.primaryLight),
                            ),
                            const SizedBox(height: AppConstants.paddingMedium),
                            CustomTextField(
                              labelText: "Display Name",
                              hintText: 'Display Name', // Changed from labelText
                              controller: _displayNameController,
                              keyboardType: TextInputType.name,
                              validator: (value) => Validators.isNotEmpty(value, 'Display Name'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingExtraLarge),

                    // --- Career Goals Section ---
                    AppTheme.applyGlassmorphism(
                      blurX: 15.0, blurY: 15.0, opacity: 0.1,
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.paddingLarge),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Career Goals (Max ${AppConstants.maxCareerGoals})',
                              style: AppTextStyles.heading3.copyWith(color: AppColors.primaryLight),
                            ),
                            const SizedBox(height: AppConstants.paddingMedium),
                            Text(
                              'What are your primary career aspirations? Add up to ${AppConstants.maxCareerGoals} goals to help us customize your mock interviews.',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                            ),
                            const SizedBox(height: AppConstants.paddingMedium),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    labelText: "Add a career goal ",
                                    hintText: 'Add a career goal', // Changed from labelText
                                    controller: _careerGoalController,
                                    textInputAction: TextInputAction.done,
                                    onEditingComplete: _addCareerGoal,
                                  ),
                                ),
                                const SizedBox(width: AppConstants.paddingSmall),
                                CustomButton(
                                  text: 'ADD',
                                  onPressed: _addCareerGoal,
                                  isSecondary: true,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                                    minimumSize: const Size(0, 48), // Ensure button height matches text field
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.paddingMedium),
                            Wrap(
                              spacing: AppConstants.paddingSmall,
                              runSpacing: AppConstants.paddingSmall,
                              children: _careerGoals.asMap().entries.map((entry) {
                                final index = entry.key;
                                final goal = entry.value;
                                return Chip(
                                  label: Text(
                                    goal,
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimaryDark),
                                  ),
                                  backgroundColor: AppColors.primaryLight.withOpacity(0.2), // Glassy chip
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                                    side: BorderSide(color: AppColors.primaryLight.withOpacity(0.4)),
                                  ),
                                  deleteIcon: Icon(Icons.close, size: AppConstants.iconSizeSmall, color: AppColors.textSecondaryDark),
                                  onDeleted: () => _removeCareerGoal(index),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingExtraLarge),

                    // --- Action Buttons ---
                    CustomButton(
                      text: 'SAVE PROFILE',
                      onPressed: _handleProfileSetup,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Full screen loading indicator
          if (_isLoading)
            const LoadingWidget(
              isFullScreen: true,
              message: 'Saving profile...',
            ),
        ],
      ),
    );
  }
}
