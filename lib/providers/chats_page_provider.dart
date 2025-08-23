import 'dart:async';

import 'package:chatify_app/models/chat.dart';
import 'package:chatify_app/models/chat_message.dart';
import 'package:chatify_app/models/chat_user.dart';
import 'package:chatify_app/providers/authentication_provider.dart';
import 'package:chatify_app/utils/my_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../services/database_service.dart';

class ChatsPageProvider extends ChangeNotifier {
  AuthenticationProvider _auth;
  late DatabaseService _db;
  late StreamSubscription _chatsStream;

  List<Chat>? chats;

  @override
  void dispose() {
    _chatsStream.cancel();
    super.dispose();
  }

  ChatsPageProvider(this._auth) {
    _db = GetIt.instance.get<DatabaseService>();
    loadChats();
  }

  Future<void> loadChats() async {
    try {
      _chatsStream = _db.getUserChats(_auth.user!.uid).listen((snapshot) async {
        // Here are the steps to import any document
        // 1. Get the document snapshot
        // 2. Convert the document snapshot to a map
        // 3. Use the map to create your model object
        chats = await Future.wait(
          snapshot.docs.map((chatDoc) async {
            // Store the chat document data in a map
            Map<String, dynamic> chatData =
                chatDoc.data() as Map<String, dynamic>;
            // Get Users in chat
            List<ChatUser> members = [];
            for (var uid in chatData['members']) {
              DocumentSnapshot userDoc = await _db.getUser(uid);
              // --- SOLUTION: Check if the document exists before using its data ---
              if (userDoc.exists) {
                // MyLogger.yellow(userDoc.data().toString());
                Map<String, dynamic> userData =
                    userDoc.data() as Map<String, dynamic>;

                // Here We set the uid for the map, because it's not provided in the data
                userData['uid'] = userDoc.id;
                members.add(ChatUser.fromJSON(userData));
              } else {
                // Optional: Log that a user was not found
                MyLogger.red("User with ID '$uid' not found in a chat.");
              }
            }
            // Get the last message
            List<ChatMessage> messages = [];
            QuerySnapshot messageSnap = await _db.getLastMessageInChat(
              chatDoc.id,
            );
            if (messageSnap.docs.isNotEmpty) {
              // making sure the query isn't empty
              Map<String, dynamic> messageData =
                  messageSnap.docs.first.data() as Map<String, dynamic>;
              messages.add(ChatMessage.fromJSON(messageData));
            }
            // return Chat instance for every chatDoc
            return Chat(
              uid: chatDoc.id,
              currentUserUid: _auth.user!.uid,
              members: members,
              messages: messages,
              activity: chatData['is_activity'] ?? false,
              group: chatData['is_group'] ?? false,
            );
          }).toList(),
        );
        notifyListeners();
      });
    } catch (e) {
      MyLogger.red("Error loading chats: $e");
    }
  }
}
