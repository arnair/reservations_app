import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reservations_app/features/authentication/application/auth_service.dart';
import 'package:reservations_app/features/authentication/domain/user_model.dart';
import 'package:reservations_app/features/authentication/data/user_repository.dart';

class AuthController {
  final _authService = AuthService();
  final _userRepository = UserRepository();
  final _auth = FirebaseAuth.instance;

  Future<void> signOutUser(BuildContext context) async {
    await _authService.signout();
  }

  Future<dynamic> loginUser(String email, String password) async {
    final user =
        await _authService.loginUserWithEmailAndPassword(email, password);
    if (user != null) {
      log("User Logged In");

      // Update lastLogin timestamp
      final existingUser = await _userRepository.getUserById(user.uid);
      if (existingUser != null) {
        // Update lastLogin
        final updatedUser = existingUser.copyWithUpdatedLogin();
        await _userRepository.saveUser(updatedUser);
        log("Last login timestamp updated");
      }
    }
    return user;
  }

  Future<dynamic> signupUser(String name, String email, String password) async {
    final user =
        await _authService.createUserWithEmailAndPassword(email, password);
    if (user != null) {
      log("User Created Successfully");

      // Create user model
      final userModel = UserModel.fromAuth(
        uid: user.uid,
        name: name,
        email: email,
      );

      // Save to Firestore
      await _userRepository.saveUser(userModel);
      log("User data saved to Firestore");
    }
    return user;
  }

  // Get current user data from Firestore
  Future<UserModel?> getCurrentUserData() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      return await _userRepository.getUserById(currentUser.uid);
    }
    return null;
  }
}
