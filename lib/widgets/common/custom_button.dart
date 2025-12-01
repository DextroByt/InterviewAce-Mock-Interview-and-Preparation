// lib/widgets/common/custom_button.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart'; // Corrected path
import '../../core/constants/app_text_styles.dart'; // Corrected path
import '../../core/constants/app_constants.dart'; // Corrected path
import 'dart:ui'; // For ImageFilter.blur

// A reusable button component that ensures consistent styling and behavior
// across the application, adhering to the Glassmorphism theme.

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Made onPressed nullable
  final bool isLoading;
  final ButtonStyle? style; // Allow overriding the default button style
  final Widget? icon; // Optional icon for the button
  final bool isSecondary; // To use secondary colors/theme for the button
  final bool isOutline; // For outlined button style

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed, // Still required, but can be null
    this.isLoading = false,
    this.style,
    this.icon,
    this.isSecondary = false,
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // final theme = Theme.of(context); // Not directly used here

    // Determine base colors for the button
    Color backgroundColor = isSecondary
        ? (isDarkMode ? AppColors.secondaryLight : AppColors.secondary)
        : (isDarkMode ? AppColors.primaryLight : AppColors.primary);
    Color foregroundColor = isSecondary
        ? (isDarkMode ? AppColors.backgroundDark : Colors.white)
        : (isDarkMode ? AppColors.backgroundDark : Colors.white);
    Color borderColor = isSecondary
        ? (isDarkMode ? AppColors.secondaryLight : AppColors.secondary)
        : (isDarkMode ? AppColors.primaryLight : AppColors.primary);

    // Text style for the button
    TextStyle buttonTextStyle = AppTextStyles.buttonText.copyWith(
      color: isOutline ? borderColor : foregroundColor,
    );

    // Determine the child widget (text or loading indicator)
    Widget buttonChild = isLoading
        ? SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        color: isOutline ? borderColor : foregroundColor,
        strokeWidth: 2,
      ),
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(width: AppConstants.paddingSmall / 2),
        ],
        Text(text, style: buttonTextStyle),
      ],
    );

    // Common shape for all buttons
    final roundedRectangleBorder = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
    );

    // Define the button based on isOutline property
    Widget button;
    if (isOutline) {
      button = OutlinedButton(
        onPressed: isLoading ? null : onPressed, // onPressed is now nullable
        style: OutlinedButton.styleFrom(
          foregroundColor: borderColor, // Text/icon color
          side: BorderSide(color: borderColor, width: 1), // Border color and width
          shape: roundedRectangleBorder,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          textStyle: buttonTextStyle,
        ).merge(style), // Merge with any provided custom style
        child: buttonChild,
      );
    } else {
      button = ElevatedButton(
        onPressed: isLoading ? null : onPressed, // onPressed is now nullable
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: roundedRectangleBorder,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          textStyle: buttonTextStyle,
          elevation: 3, // Subtle shadow
        ).merge(style), // Merge with any provided custom style
        child: buttonChild,
      );
    }

    // Apply glassmorphism effect to the button in dark mode
    if (isDarkMode && !isOutline) { // Apply only to filled buttons in dark mode
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Subtle blur
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.2), // Transparent background with primary/secondary tint
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              border: Border.all(
                color: borderColor.withOpacity(0.1), // Very subtle border
                width: 1,
              ),
            ),
            child: button,
          ),
        ),
      );
    }
    return button;
  }
}
