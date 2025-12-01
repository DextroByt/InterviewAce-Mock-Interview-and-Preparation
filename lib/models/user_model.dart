// lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

// This file defines the data structure for a User in the application.
// It includes properties for user details and methods for converting
// to/from JSON (for Firestore or API responses).

class UserModel {
  final String uid; // User ID from Firebase Auth
  final String email;
  final String displayName;
  final String? profilePicturePath; // Changed from profilePictureUrl
  final List<String> careerGoals;
  final String? quizBadge; // NEW: Field to store the user's highest quiz badge
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  // Constructor for creating a UserModel instance
  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.profilePicturePath, // Changed from profilePictureUrl
    this.careerGoals = const [],
    this.quizBadge,
    required this.createdAt,
    this.lastLoginAt,
  });

  // Factory constructor to create a UserModel instance from a JSON map.
  // This is used when fetching data from Firestore or an API.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        uid: json['uid'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String,
        profilePicturePath: json['profilePicturePath'] as String?, // Changed from profilePictureUrl
        // Ensure careerGoals is a List<String>
        careerGoals: (json['careerGoals'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
            [],
        quizBadge: json['quizBadge'] as String?,
        // Convert Firestore Timestamp or ISO 8601 string to DateTime
        createdAt: (json['createdAt'] is Timestamp)
            ? (json['createdAt'] as Timestamp).toDate()
            : DateTime.parse(json['createdAt'] as String),
        lastLoginAt: (json['lastLoginAt'] is Timestamp)
            ? (json['lastLoginAt'] as Timestamp?)?.toDate()
            : (json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt'] as String) : null),
      );
    } catch (e) {
      debugPrint('Error parsing UserModel from JSON: $e, JSON: $json');
      rethrow; // Rethrow to indicate a parsing error
    }
  }

  // Converts the UserModel instance into a JSON map for storage.
  // This is used when saving data to Firestore or sending to an API.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'profilePicturePath': profilePicturePath, // Changed from profilePictureUrl
      'careerGoals': careerGoals,
      'quizBadge': quizBadge,
      // Convert DateTime to Firestore Timestamp or ISO 8601 string
      'createdAt': createdAt.toIso8601String(), // Using ISO 8601 for broader compatibility
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  // Utility method to create a new UserModel instance with updated properties.
  // This is useful for immutability and state management.
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? profilePicturePath, // Changed from profilePictureUrl
    List<String>? careerGoals,
    String? quizBadge,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath, // Changed from profilePictureUrl
      careerGoals: careerGoals ?? this.careerGoals,
      quizBadge: quizBadge ?? this.quizBadge,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, '
        'profilePicturePath: $profilePicturePath, careerGoals: $careerGoals, ' // Changed from profilePictureUrl
        'quizBadge: $quizBadge, createdAt: $createdAt, lastLoginAt: $lastLoginAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        other.profilePicturePath == profilePicturePath && // Changed from profilePictureUrl
        listEquals(other.careerGoals, careerGoals) && // Use listEquals for List comparison
        other.quizBadge == quizBadge &&
        other.createdAt == createdAt &&
        other.lastLoginAt == lastLoginAt;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
    email.hashCode ^
    displayName.hashCode ^
    profilePicturePath.hashCode ^ // Changed from profilePictureUrl
    careerGoals.hashCode ^
    quizBadge.hashCode ^
    createdAt.hashCode ^
    lastLoginAt.hashCode;
  }
}
