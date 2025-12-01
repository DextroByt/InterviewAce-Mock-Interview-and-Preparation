// lib/screens/auth/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // For ImageFilter.blur

import '../../core/constants/app_colors.dart'; // Corrected path
import '../../core/constants/app_constants.dart'; // Corrected path
import '../../core/constants/app_text_styles.dart'; // Corrected path
import '../../core/utils/validators.dart'; // Corrected path
import '../../core/utils/helpers.dart'; // Corrected path
import '../../core/theme/app_theme.dart'; // For glassmorphism effect
import '../../providers/auth_provider.dart'; // Corrected path
import '../../widgets/common/custom_text_field.dart'; // Corrected path
import '../../widgets/common/custom_button.dart'; // Corrected path
import '../../widgets/common/loading_widget.dart'; // Corrected path

import 'login_screen.dart'; // For navigation back to login
import '../onboarding/profile_setup_screen.dart'; // For navigation after successful signup

// This screen provides the user interface for registering a new account,
// adhering to the Glassmorphism theme and integrating with AuthProvider.
// It includes advanced animations for a more professional look.

class SignUpScreen extends StatefulWidget {
  static const String routeName = '/signup';

  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin { // Added SingleTickerProviderStateMixin
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Total animation duration
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2), // Start slightly below
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Start the animation after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose(); // Dispose animation controller
    super.dispose();
  }

  // Handles the sign-up process when the button is pressed.
  Future<void> _handleSignUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.signup(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        // On successful signup, navigate to the profile setup screen.
        // The AuthProvider's listener in app.dart will handle the actual redirection
        // after Firebase user is created, but we explicitly push to profile setup here.
        Helpers.showSnackbar(context, 'Registration successful! Please set up your profile.', backgroundColor: AppColors.success);
        Navigator.of(context).pushReplacementNamed(ProfileSetupScreen.routeName);
      } catch (e) {
        // Error is already an AuthException from AuthProvider
        Helpers.showSnackbar(context, e.toString(), backgroundColor: AppColors.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    // final isDarkMode = Theme.of(context).brightness == Brightness.dark; // Not directly used for background color here

    return Scaffold(
      backgroundColor: AppColors.backgroundDark, // Consistent dark background
      body: Stack(
        children: [
          // Advanced Background - Subtle Animated Gradient
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(seconds: 5), // Duration for background animation
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft, // Different begin/end for variety
                  end: Alignment.topRight,
                  colors: [
                    AppColors.backgroundDark,
                    AppColors.primaryDark.withOpacity(0.8), // Darker primary for subtle glow
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
                    // --- Welcome Section with Fade and Slide Animation ---
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            Text(
                              'Join InterviewAce!',
                              style: AppTextStyles.heading1.copyWith(
                                color: AppColors.textPrimaryDark,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppConstants.paddingMedium),
                            Text(
                              'Create your free account to start your AI-powered interview prep.',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textSecondaryDark,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingExtraLarge * 1.5),

                    // --- Sign Up Form Container (Enhanced Glassmorphism + Animation) ---
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.4), // Start further below
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic), // Start later
                          ),
                        ),
                        child: AppTheme.applyGlassmorphism(
                          // Using the helper from AppTheme for glassmorphism effect
                          blurX: 15.0, // More blur for a stronger effect
                          blurY: 15.0,
                          opacity: 0.1, // Even more transparent
                          overlayColor: AppColors.surfaceDark, // Use surfaceDark for the tint
                          child: Padding(
                            padding: const EdgeInsets.all(AppConstants.paddingLarge),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Sign Up',
                                  style: AppTextStyles.heading2.copyWith(
                                    color: AppColors.textPrimaryDark,
                                  ),
                                ),
                                const SizedBox(height: AppConstants.paddingLarge),
                                CustomTextField(
                                  labelText: 'Email',
                                  hintText: 'Enter your email',
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) => Validators.isValidEmail(value),
                                ),
                                const SizedBox(height: AppConstants.paddingMedium),
                                CustomTextField(
                                  labelText: 'Password',
                                  hintText: 'Create a password',
                                  controller: _passwordController,
                                  obscureText: true,
                                  keyboardType: TextInputType.visiblePassword,
                                  validator: (value) => Validators.isValidPassword(value),
                                ),
                                const SizedBox(height: AppConstants.paddingMedium),
                                CustomTextField(
                                  labelText: 'Confirm Password',
                                  hintText: 'Re-enter your password',
                                  controller: _confirmPasswordController,
                                  obscureText: true,
                                  keyboardType: TextInputType.visiblePassword,
                                  validator: (value) => Validators.isMatching(
                                    value,
                                    _passwordController.text,
                                    'Passwords',
                                  ),
                                  textInputAction: TextInputAction.done,
                                  onEditingComplete: _handleSignUp, // Trigger signup on done
                                ),
                                const SizedBox(height: AppConstants.paddingLarge),
                                CustomButton(
                                  text: 'SIGN UP',
                                  onPressed: _handleSignUp,
                                  isLoading: authProvider.isLoading,
                                  isSecondary: true, // Use secondary color for signup button
                                ),
                                const SizedBox(height: AppConstants.paddingMedium),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Already have an account?",
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondaryDark,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
                                      },
                                      child: Text(
                                        'Login',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.primaryLight,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Full screen loading indicator
          if (authProvider.isLoading)
            const LoadingWidget(
              isFullScreen: true,
              message: 'Registering...',
            ),
        ],
      ),
    );
  }
}
