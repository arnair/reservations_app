import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:toastification/toastification.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      log(e.message!);
      toastification.show(
          title: Text(e.message!),
          autoCloseDuration: const Duration(seconds: 5),
          type: ToastificationType.error);
    }
    return null;
  }

  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      log(e.message!);
      toastification.show(
          title: Text(e.message!),
          autoCloseDuration: const Duration(seconds: 5),
          type: ToastificationType.error);
    }
    return null;
  }

  Future<void> signout() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      log(e.message!);
      toastification.show(
          title: Text(e.message!),
          autoCloseDuration: const Duration(seconds: 5),
          type: ToastificationType.error);
    }
  }
}
