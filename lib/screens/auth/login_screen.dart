// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // For ImageFilter.blur

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_widget.dart';

import '../home/home_screen.dart';
import 'signup_screen.dart';

// This screen provides the user interface for logging into the application,
// featuring a welcome section, login form, and adhering to the Glassmorphism theme.
// It now seamlessly integrates the forgot password functionality into the main view.

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _forgotPasswordEmailController = TextEditingController();
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _forgotPasswordFormKey = GlobalKey<FormState>();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // New state variable to toggle between login and forgot password views
  bool _isLoginView = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _forgotPasswordEmailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Handles the login process when the button is pressed.
  Future<void> _handleLogin() async {
    if (_loginFormKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        }
        Helpers.showSnackbar(context, 'Login successful!', backgroundColor: AppColors.success);
      } catch (e) {
        Helpers.showSnackbar(context, e.toString(), backgroundColor: AppColors.error);
      }
    }
  }

  // NEW: Handles the forgot password process
  Future<void> _handleForgotPassword() async {
    if (_forgotPasswordFormKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.sendPasswordResetEmail(_forgotPasswordEmailController.text.trim());
        if (mounted) {
          Helpers.showSnackbar(context, 'Password reset link sent! Check your email.', backgroundColor: AppColors.success);
          // Return to the login view after sending the email
          setState(() {
            _isLoginView = true;
          });
        }
      } catch (e) {
        Helpers.showSnackbar(context, e.toString(), backgroundColor: AppColors.error);
      }
    }
  }

  // Widget to build the login form
  Widget _buildLoginForm(BuildContext context, AuthProvider authProvider) {
    return Form(
      key: _loginFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Login',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          CustomTextField(
            labelText: "Email",
            hintText: 'Enter your email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) => Validators.isValidEmail(value),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          CustomTextField(
            labelText: "Password",
            hintText: 'Enter your password',
            controller: _passwordController,
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            validator: (value) => Validators.isValidPassword(value),
            textInputAction: TextInputAction.done,
            onEditingComplete: _handleLogin,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          CustomButton(
            text: 'LOGIN',
            onPressed: _handleLogin,
            isLoading: authProvider.isLoading,
            isSecondary: false,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          TextButton(
            onPressed: () {
              setState(() {
                _isLoginView = false;
              });
            },
            child: Text(
              'Forgot Password?',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryLight,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account?",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(SignUpScreen.routeName);
                },
                child: Text(
                  'Sign Up',
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
    );
  }

  // NEW: Widget to build the forgot password form
  Widget _buildForgotPasswordForm(BuildContext context, AuthProvider authProvider) {
    return Form(
      key: _forgotPasswordFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Reset Password',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          Text(
            'Enter your email address below and we\'ll send you a link to reset your password.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          CustomTextField(
            labelText: "Email",
            hintText: 'Enter your email',
            controller: _forgotPasswordEmailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) => Validators.isValidEmail(value),
            textInputAction: TextInputAction.done,
            onEditingComplete: _handleForgotPassword,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          CustomButton(
            text: 'SEND RESET LINK',
            onPressed: _handleForgotPassword,
            isLoading: authProvider.isLoading,
            isSecondary: false,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          TextButton(
            onPressed: () {
              setState(() {
                _isLoginView = true;
              });
            },
            child: Text(
              'Back to Login',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

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
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          Text(
                            'Welcome to InterviewAce!',
                            style: AppTextStyles.heading1.copyWith(
                              color: AppColors.textPrimaryDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppConstants.paddingMedium),
                          Text(
                            'Your AI-powered interview preparation companion.',
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
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.4),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
                        ),
                      ),
                      child: AppTheme.applyGlassmorphism(
                        blurX: 15.0,
                        blurY: 15.0,
                        opacity: 0.1,
                        overlayColor: AppColors.surfaceDark,
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.paddingLarge),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: _isLoginView
                                ? _buildLoginForm(context, authProvider)
                                : _buildForgotPasswordForm(context, authProvider),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (authProvider.isLoading)
            const LoadingWidget(
              isFullScreen: true,
              message: 'Loading...',
            ),
        ],
      ),
    );
  }
}
