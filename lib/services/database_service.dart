import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/my_logger.dart';

const String USER_COLLECTION = "Users";
const String CHAT_COLLECTION = "Chats";
const String MESSAGES_COLLECTION = "messages";

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DatabaseService();

  Future<DocumentSnapshot> getUser(String uid) async {
    return await _db.collection(USER_COLLECTION).doc(uid).get();
  }

  Future<void> updateLastSeen(String uid) async {
    await _db.collection(USER_COLLECTION).doc(uid).update({
      'last_active': DateTime.now().toUtc(),
    });
  }

  Future<void> createUser(
    String uid,
    String email,
    String name,
    String imageUrl,
  ) async {
    try {
      await _db.collection(USER_COLLECTION).doc(uid).set({
        'email': email,
        'name': name,
        'image': imageUrl,
        'last_active': DateTime.now().toUtc(),
      });
    } catch (e) {
      MyLogger.red("Error creating user: $e");
    }
  }
}
