// lib/widgets/ai_character.dart

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_text_styles.dart';

// This widget displays a realistic AI character (static image) that can
// visually indicate when it is speaking using a subtle animation.
// It can now be configured for a circular avatar or a full-bleed background image.

class AiCharacter extends StatefulWidget {
  final bool isSpeaking;
  final String gender; // 'male' or 'female'
  final double? size; // Optional size for circular avatar. If null, it fills parent.
  final BoxFit fit; // How the image should be inscribed into the box.
  final bool isBackground; // If true, it's treated as a background image, removes circular clipping/decoration.

  const AiCharacter({
    super.key,
    required this.isSpeaking,
    required this.gender,
    this.size,
    this.fit = BoxFit.contain,
    this.isBackground = false,
  });

  @override
  AiCharacterState createState() => AiCharacterState();
}

class AiCharacterState extends State<AiCharacter> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  // FIX: The CurvedAnimation was causing the error and is not needed.
  // The controller itself will animate between the lower and upper bounds.

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200), // Slower, more natural pulse
      lowerBound: 0.98, // Subtle pulse effect
      upperBound: 1.02,
    );

    if (widget.isSpeaking) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AiCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSpeaking != widget.isSpeaking) {
      if (widget.isSpeaking) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.animateTo(1.0, curve: Curves.easeOut, duration: const Duration(milliseconds: 300)); // Animate back to normal size
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String imagePath = widget.gender == 'male'
        ? 'assets/images/male_interviewer_real2.png'
        : 'assets/images/female_interviewer_real2.png';

    Widget imageWidget = Image.asset(
      imagePath,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Text(
            widget.gender == 'male' ? '👨‍💼' : '👩‍💼',
            style: AppTextStyles.heading1.copyWith(fontSize: (widget.size ?? 250) * 0.4),
          ),
        );
      },
    );

    // The ScaleTransition now uses the controller directly.
    // The controller's value will animate between the lower and upper bounds.
    Widget animatedCharacter = ScaleTransition(
      scale: _pulseController,
      child: imageWidget,
    );

    if (widget.isBackground) {
      return animatedCharacter;
    } else {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceDark.withOpacity(0.3),
          border: Border.all(
            color: widget.isSpeaking
                ? AppColors.primaryLight.withOpacity(0.8)
                : AppColors.primaryLight.withOpacity(0.2),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isSpeaking
                  ? AppColors.primaryLight.withOpacity(0.5)
                  : Colors.black.withOpacity(0.3),
              blurRadius: widget.isSpeaking ? 25 : 15,
              spreadRadius: widget.isSpeaking ? 3 : 0,
            ),
          ],
        ),
        child: ClipOval(
          child: animatedCharacter,
        ),
      );
    }
  }
}
