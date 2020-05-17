import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class Auth {
  Future<String> signInWithEmailPassword(String email, String password);
  Future<String> createAccWithEmailPassword(String email, String password);
  Future<void> signOut();
  Future<String> currentUser();
  Stream<String> get onAuthStateChanged;
}

class FirebaseAuthentication implements Auth {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Stream<String> get onAuthStateChanged {
    return _firebaseAuth.onAuthStateChanged.map((user) => user?.uid);
  }

  @override
  Future<String> signInWithEmailPassword(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password)
      .then((result) => result.user);
    return user.uid;
  }

  @override
  Future<String> createAccWithEmailPassword(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)
      .then((result) => result.user);
    return user.uid;
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