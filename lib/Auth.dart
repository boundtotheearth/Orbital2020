import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class Auth {
  Future<String> signInWithEmailPassword(String email, String password);
  Future<String> createAccWithEmailPassword(String name, String email, String password);
  Future<void> signOut();
  Future<String> currentUser();
  Stream<FirebaseUser> get onAuthStateChanged;
}

class FirebaseAuthentication implements Auth {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Stream<FirebaseUser> get onAuthStateChanged {
    return _firebaseAuth.onAuthStateChanged;
  }

  @override
  Future<String> signInWithEmailPassword(String email, String password) async {
    try {
      FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password)
          .then((result) => result.user);
      return user.uid;
    } catch (error) {
      print(error);
      return null;
    }
  }

  @override
  Future<String> createAccWithEmailPassword(String name, String email, String password) async {
    try {
      FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password)
          .then((result) => result.user);
      UserUpdateInfo updateName = UserUpdateInfo();
      updateName.displayName = name;
      await user.updateProfile(updateName);
      return user.uid;
    } catch (error) {
      print(error);
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<String> currentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.uid;
  }

}