import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  final String userId;
  final String userName;
  final String userEmail;
  final String userImage; // Optional, in case you store a user image URL
  final String role; // Added to represent the user role (e.g., user/admin)
  final String noHp; // Added to represent the user's phone number
  final Timestamp createdAt; // The timestamp when the user was created

  UserModel({
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userImage = '', // Default to empty if no image is provided
    required this.role,
    required this.noHp,
    required this.createdAt,
  });

  // Factory method to create a UserModel from Firestore data
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserModel(
      userId: data['user_id'] ?? '', // Fetch user_id field from Firestore
      userName: data['user_name'] ?? '', // Fetch user_name field
      userEmail: data['email'] ?? '', // Fetch email field
      userImage: data['user_image'] ?? '', // Fetch user_image field if present
      role: data['role'] ?? 'user', // Fetch role field, default to 'user'
      noHp: data['no_hp']?.toString() ?? '', // Fetch no_hp field as a string
      createdAt: data['createdAt'] ?? Timestamp.now(), // Fetch createdAt field
    );
  }

  // Convert UserModel to a map to store data back to Firestore
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'user_name': userName,
      'email': userEmail,
      'user_image': userImage,
      'role': role,
      'no_hp': noHp,
      'createdAt': createdAt,
    };
  }
}
