// lib/core/utils/helpers.dart

import 'package:flutter/material.dart';

// This file contains various general-purpose helper functions that can be reused
// across different parts of the application.

class Helpers {
  // Displays a temporary message to the user using a SnackBar.
  static void showSnackbar(BuildContext context, String message, {Color? backgroundColor, Color? textColor}) {
    // Ensure the ScaffoldMessenger is available
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor ?? Colors.white),
        ),
        backgroundColor: backgroundColor ?? Colors.grey[800],
        duration: const Duration(seconds: 3), // Default duration
        behavior: SnackBarBehavior.floating, // Makes it float above content
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded corners for the snackbar
        ),
        margin: const EdgeInsets.all(10), // Margin from the edges
      ),
    );
  }

  // Formats a Duration object into a human-readable string (e.g., "05:30" for 5 minutes 30 seconds).
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final hours = twoDigits(duration.inHours);

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  // Converts an enum value to its string representation.
  // Example: getEnumString(MyEnum.value) returns "value"
  static String getEnumString(dynamic enumValue) {
    return enumValue.toString().split('.').last;
  }

  // A utility for introducing a delay.
  static Future<void> delay(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  // Formats a DateTime object into a human-readable date and time string.
  static String formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

// You can add more helper functions here as needed, e.g.:
// static bool isKeyboardOpen(BuildContext context) {
//   return MediaQuery.of(context).viewInsets.bottom != 0;
// }
}

