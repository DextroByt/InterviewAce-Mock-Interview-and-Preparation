// lib/core/utils/validators.dart

// This file provides utility functions for input validation.
// These functions are used to ensure data integrity for forms and user inputs.

class Validators {
  // Validates if a given string is a well-formed email address.
  // Returns null if valid, otherwise an error message string.
  static String? isValidEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email cannot be empty.';
    }
    // Basic regex for email validation. More robust regex can be used if needed.
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }
    return null; // No error
  }

  // Validates password strength based on predefined criteria.
  // Criteria: minimum 8 characters, at least one uppercase, one lowercase, one digit.
  // Returns null if valid, otherwise an error message string.
  static String? isValidPassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password cannot be empty.';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter.';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter.';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one digit.';
    }
    // Optional: Add special character validation
    // if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
    //   return 'Password must contain at least one special character.';
    // }
    return null; // No error
  }

  // Checks if a string is not empty or null.
  // Returns null if valid (not empty), otherwise an error message string.
  static String? isNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty.';
    }
    return null; // No error
  }

  // Compares two strings for equality. Useful for password confirmation.
  // Returns null if they match, otherwise an error message string.
  static String? isMatching(String? value1, String? value2, String fieldName) {
    if (value1 != value2) {
      return '$fieldName do not match.';
    }
    return null; // No error
  }
}

