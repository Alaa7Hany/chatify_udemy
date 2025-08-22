import 'dart:io';

import 'package:chatify_app/utils/my_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

const String User_Collection = 'Users';
const String User_Images_Path = 'images/users/';
const String Chat_Images_Path = 'images/chats/';

class CloudStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CloudStorageService();

  Future<String?> uploadUserImage(String uid, PlatformFile file) async {
    try {
      // Create a refrence to the place where the image will
      // be saved
      Reference ref = _storage.ref().child(
        '$User_Images_Path$uid/${file.name}.${file.extension}',
      );
      UploadTask task = ref.putFile(File(file.path!));
      // after uploading, return the url for the image
      return await task.then((result) => result.ref.getDownloadURL());
    } catch (e) {
      MyLogger.red("Error uploading user image: $e");
      return null;
    }
  }

  Future<String?> uploadChatImage(
    String chatId,
    String uid,
    PlatformFile file,
  ) async {
    try {
      Reference ref = _storage.ref().child(
        '$Chat_Images_Path$chatId/${uid}_${Timestamp.now().millisecondsSinceEpoch}.${file.extension}',
      );
      UploadTask task = ref.putFile(File(file.path!));
      return await task.then((result) => result.ref.getDownloadURL());
    } catch (e) {
      MyLogger.red("Error uploading chat image: $e");
      return null;
    }
  }
}
