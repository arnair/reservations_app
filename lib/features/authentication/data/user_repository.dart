import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reservations_app/features/authentication/domain/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Create or update a user in Firestore
  Future<void> saveUser(UserModel user) async {
    try {
      await _firestore.collection(_collection).doc(user.id).set(
            user.toJson(),
            SetOptions(merge: true),
          );
    } catch (e) {
      throw Exception('Failed to save user: $e');
    }
  }

  // Get a user by their ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Check if a user exists in Firestore
  Future<bool> userExists(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check if user exists: $e');
    }
  }

  // Delete a user from Firestore
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}
