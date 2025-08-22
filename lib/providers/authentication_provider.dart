import 'package:chatify_app/models/chat_user.dart';
import 'package:chatify_app/services/database_service.dart';
import 'package:chatify_app/services/navigation_service.dart';
import 'package:chatify_app/utils/my_logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthenticationProvider extends ChangeNotifier {
  late final FirebaseAuth _auth;
  late final DatabaseService _database;
  late final NavigationService _navigation;
  late ChatUser? user;

  AuthenticationProvider() {
    _auth = FirebaseAuth.instance;
    _database = DatabaseService();
    _navigation = NavigationService();

    // _auth.signOut();

    _auth.authStateChanges().listen((currentUser) {
      if (currentUser == null) {
        user = null;
        MyLogger.red("User is currently signed out.");
        _navigation.removeAndNavigateToRoute('login');
      } else {
        MyLogger.yellow('ghdfkjghdslkfjdsalkdkmsa;ldmsf.smf.ds');
        _database.updateLastSeen(currentUser.uid);
        _database.getUser(currentUser.uid).then((snapshot) {
          Map<String, dynamic> userData =
              snapshot.data() as Map<String, dynamic>;
          user = ChatUser.fromJSON({
            'uid': currentUser.uid,
            'name': userData['name'],
            'email': userData['email'],
            'image': userData['image'],
            'last_active': userData['last_active'],
          });
          MyLogger.green(user!.toMap().toString());
          _navigation.removeAndNavigateToRoute('home');
        });
        MyLogger.magenta("User is signed in: ${currentUser.uid}");
      }
    });
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      MyLogger.red("FirebaseAuthException: ${e.message}");
    } catch (e) {
      MyLogger.red("Error logging in: $e");
    }
  }

  Future<String?> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      MyLogger.red("FirebaseAuthException: ${e.message}");
    } catch (e) {
      MyLogger.red("Error registering: $e");
    }
    return null;
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      user = null;
    } catch (e) {
      MyLogger.red("Error logging out: $e");
    }
  }
}
