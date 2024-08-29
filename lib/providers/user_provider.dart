import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopsmart_users_en/models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? userModel;
  UserModel? get getUserModel {
    return userModel;
  }

  Future<UserModel?> fetchUserInfo() async {
    final auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user == null) {
      return null;
    }
    String uid = user.uid;
    try {
      // Reference to the new Firestore collection 'dataPengguna'
      final userDoc = await FirebaseFirestore.instance
          .collection("dataPengguna")
          .doc(uid)
          .get();

      final userDocDict = userDoc.data();

      if (userDocDict == null) {
        return null;
      }

      // Populate the userModel with data fetched from Firestore
      userModel = UserModel(
        userId: userDoc.get("user_id"),
        userName: userDoc.get("user_name"),
        userEmail: userDoc.get('email'),
        userImage: userDoc.get("user_image") ?? '', // Optional, with default
        role: userDoc.get("role") ?? 'user', // Optional, default to 'user'
        noHp: userDoc.get("no_hp")?.toString() ?? '', // Ensure it's a string
        createdAt: userDoc.get('createdAt') ?? Timestamp.now(),
      );

      notifyListeners(); // Notify listeners about the change
      return userModel;
    } on FirebaseException catch (error) {
      print('Error fetching user info: $error');
      rethrow;
    } catch (error) {
      print('Error fetching user info: $error');
      rethrow;
    }
  }

  Future<void> saveUserInfo(UserModel userModel) async {
    try {
      await FirebaseFirestore.instance
          .collection("dataPengguna")
          .doc(userModel.userId)
          .set(userModel.toMap());
      notifyListeners();
    } on FirebaseException catch (error) {
      print('Error saving user info: $error');
      rethrow;
    } catch (error) {
      print('Error saving user info: $error');
      rethrow;
    }
  }
}
