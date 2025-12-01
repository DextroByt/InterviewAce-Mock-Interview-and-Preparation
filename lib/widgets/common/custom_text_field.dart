// lib/widgets/common/custom_text_field.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart'; // Corrected path
import '../../core/constants/app_text_styles.dart'; // Corrected path
import '../../core/constants/app_constants.dart'; // Corrected path
import '../../core/theme/app_theme.dart'; // For glassmorphism effect

// A themed text input component that provides consistent styling,
// validation feedback, and functionality, adhering to the Glassmorphism theme.

class CustomTextField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.onChanged,
    this.onEditingComplete,
    this.focusNode,
    this.textInputAction,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscure;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    // Determine the fill color based on theme and Glassmorphism principles
    Color fillColor = isDarkMode
        ? AppColors.surfaceDark.withOpacity(0.2) // Subtle transparency for dark mode
        : AppColors.surfaceLight;

    // Determine border color based on theme
    Color borderColor = isDarkMode
        ? AppColors.textSecondaryDark.withOpacity(0.3)
        : AppColors.textSecondaryLight.withOpacity(0.3);

    // Determine focused border color
    Color focusedBorderColor = isDarkMode ? AppColors.primaryLight : AppColors.primary;

    return Container(
      // Apply glassmorphism effect to the container in dark mode
      decoration: isDarkMode
          ? BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      )
          : null, // No special decoration for light mode, rely on InputDecoration
      child: ClipRRect( // Clip for rounded corners if using BackdropFilter
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: isDarkMode ? BackdropFilter( // Apply blur only in dark mode
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Subtle blur
          child: _buildTextFormField(theme, fillColor, focusedBorderColor),
        ) : _buildTextFormField(theme, fillColor, focusedBorderColor),
      ),
    );
  }

  Widget _buildTextFormField(ThemeData theme, Color fillColor, Color focusedBorderColor) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _isObscure,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      onChanged: widget.onChanged,
      onEditingComplete: widget.onEditingComplete,
      focusNode: widget.focusNode,
      textInputAction: widget.textInputAction,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface, // Text color adapts to theme
      ),
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6), // Hint color adapts
        ),
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.8), // Label color adapts
        ),
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none, // No default border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none, // No border for enabled state, rely on container/glassmorphism
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: focusedBorderColor, width: 2), // Primary color border when focused
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText
            ? IconButton(
          icon: Icon(
            _isObscure ? Icons.visibility_off : Icons.visibility,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          onPressed: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
        )
            : widget.suffixIcon,
      ),
    );
  }
}
