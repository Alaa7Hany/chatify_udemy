import 'package:chatify_app/models/chat_message.dart';
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

  Stream<QuerySnapshot> getUserChats(String uid) {
    return _db
        .collection(CHAT_COLLECTION)
        .where('members', arrayContains: uid)
        .snapshots();
  }

  Future<QuerySnapshot> getLastMessageInChat(String chatID) async {
    return _db
        .collection(CHAT_COLLECTION)
        .doc(chatID)
        .collection(MESSAGES_COLLECTION)
        .orderBy('sent_time', descending: true)
        .limit(1)
        .get();
  }

  Stream<QuerySnapshot> getChatMessagesStream(String chatId) {
    return _db
        .collection(CHAT_COLLECTION)
        .doc(chatId)
        .collection(MESSAGES_COLLECTION)
        .orderBy('sent_time', descending: false)
        .snapshots();
  }

  Future<void> deleteChat(String chatId) async {
    await _db.collection(CHAT_COLLECTION).doc(chatId).delete();
  }

  Future<void> addMessageToChat(String chatId, ChatMessage message) async {
    await _db
        .collection(CHAT_COLLECTION)
        .doc(chatId)
        .collection(MESSAGES_COLLECTION)
        .add(message.toJson());
  }

  Future<void> updateChatData(String chatId, Map<String, dynamic> data) async {
    await _db.collection(CHAT_COLLECTION).doc(chatId).update(data);
  }
}
