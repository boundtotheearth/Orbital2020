import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class Auth {
  Future<String> signInWithEmailPassword(String email, String password);
  Future<String> createAccWithEmailPassword(String email, String password);
}

class FirebaseAuthentication implements Auth {

  @override
  Future<String> signInWithEmailPassword(String email, String password) async {
    FirebaseUser user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password)
      .then((result) => result.user);
    return user.uid;
  }

  @override
  Future<String> createAccWithEmailPassword(String email, String password) async {
    FirebaseUser user = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password)
      .then((result) => result.user);
    return user.uid;
  }

}