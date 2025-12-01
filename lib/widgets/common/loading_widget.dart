// lib/widgets/common/loading_widget.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart'; // Corrected path
import '../../core/constants/app_constants.dart'; // Corrected path
import '../../core/theme/app_theme.dart'; // For glassmorphism effect if needed

// Provides consistent loading indicators and states throughout the application.

class LoadingWidget extends StatelessWidget {
  final String? message; // Optional message to display below the indicator
  final bool isFullScreen; // If true, covers the entire screen
  final Color? backgroundColor; // Background color for the full screen loader
  final Color? indicatorColor; // Color of the CircularProgressIndicator

  const LoadingWidget({
    super.key,
    this.message,
    this.isFullScreen = false,
    this.backgroundColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    // Determine indicator color based on theme
    final Color effectiveIndicatorColor = indicatorColor ??
        (isDarkMode ? AppColors.primaryLight : AppColors.primary);

    // Determine background color for full screen mode
    final Color effectiveBackgroundColor = backgroundColor ??
        (isDarkMode ? AppColors.backgroundDark.withOpacity(0.8) : AppColors.backgroundLight.withOpacity(0.8));

    Widget loadingContent = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(effectiveIndicatorColor),
            strokeWidth: 3,
          ),
          if (message != null && message!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              message!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );

    if (isFullScreen) {
      return Container(
        color: effectiveBackgroundColor,
        child: loadingContent,
      );
    } else {
      return loadingContent;
    }
  }
}

