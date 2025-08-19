import 'package:firebase_storage/firebase_storage.dart';

const String User_Collection = 'Users';

class CloudStorageService {
  final FirebaseStorage storage = FirebaseStorage.instance;

  CloudStorageService();
}
