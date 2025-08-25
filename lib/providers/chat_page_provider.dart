import 'dart:async';

import 'package:chatify_app/utils/my_logger.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get_it/get_it.dart';

import '../models/chat_message.dart';
import '../services/cloud_storage_service.dart';
import '../services/database_service.dart';
import '../services/media_service.dart';
import '../services/navigation_service.dart';
import 'authentication_provider.dart';

class ChatPageProvider extends ChangeNotifier {
  late DatabaseService _db;
  late CloudStorageService _storage;
  late MediaService _media;
  late NavigationService _navigation;

  AuthenticationProvider _auth;
  ScrollController _messagesListViewController;

  late StreamSubscription _messagesStream;
  late StreamSubscription _keyboardVisibilityStream;
  late KeyboardVisibilityController _keyboardVisibilityController;

  String _chatId;
  List<ChatMessage>? messages;
  String? _messageSent;

  String get messageSent {
    return _messageSent ?? "";
  }

  void setMessageSent(String message) {
    _messageSent = message;
  }

  ChatPageProvider(this._chatId, this._auth, this._messagesListViewController) {
    _db = GetIt.instance.get<DatabaseService>();
    _storage = GetIt.instance.get<CloudStorageService>();
    _media = GetIt.instance.get<MediaService>();
    _navigation = GetIt.instance.get<NavigationService>();
    _keyboardVisibilityController = KeyboardVisibilityController();

    listenToMessages();
    listenToKeyboardChange();
  }

  @override
  void dispose() {
    _messagesStream.cancel();
    _keyboardVisibilityStream.cancel();
    super.dispose();
  }

  void listenToMessages() {
    try {
      // First: get the messages stream from the database & listen to it
      _messagesStream = _db.getChatMessagesStream(_chatId).listen((snapshot) {
        // Map every message document into a ChatMessage model
        List<ChatMessage> messages = snapshot.docs.map((messageDoc) {
          Map<String, dynamic> messageData =
              messageDoc.data() as Map<String, dynamic>;
          return ChatMessage.fromJSON(messageData);
        }).toList();
        // assign the mapped messages for the provider
        this.messages = messages;
        notifyListeners();
        // To make sure the messages list view is scrolled to the bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_messagesListViewController.hasClients) {
            _messagesListViewController.jumpTo(
              _messagesListViewController.position.maxScrollExtent,
            );
          }
        });
      });
    } catch (e) {
      MyLogger.red('error listening to messages: $e');
    }
  }

  void sendTextMessage() {
    try {
      if (_messageSent != null) {
        ChatMessage message = ChatMessage(
          content: _messageSent!,
          type: MessageType.TEXT,
          senderID: _auth.user!.uid,
          sentTime: DateTime.now().toUtc(),
        );
        _db.addMessageToChat(_chatId, message);
      }
    } catch (e) {
      MyLogger.red('error sending text message: $e');
    }
  }

  void sendImageMessage() async {
    try {
      PlatformFile? file = await _media.pickImageFromLibrary();
      if (file != null) {
        String? imageUrl = await _storage.uploadChatImage(
          _chatId,
          _auth.user!.uid,
          file,
        );
        ChatMessage message = ChatMessage(
          content: imageUrl ?? "",
          type: MessageType.IMAGE,
          senderID: _auth.user!.uid,
          sentTime: DateTime.now().toUtc(),
        );
        _db.addMessageToChat(_chatId, message);
      }
    } catch (e) {
      MyLogger.red('Error sending image: $e');
    }
  }

  void listenToKeyboardChange() {
    try {
      _keyboardVisibilityStream = _keyboardVisibilityController.onChange.listen(
        (isVisible) {
          _db.updateChatData(_chatId, {'is_activity': isVisible});
        },
      );
    } catch (e) {
      MyLogger.red('Error listening to keyboard visibility changes: $e');
    }
  }

  void deleteChat() {
    goBack();
    _db.deleteChat(_chatId);
  }

  void goBack() {
    _navigation.goBack();
  }
}
