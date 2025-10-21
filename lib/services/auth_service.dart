// ignore_for_file: unused_import

import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:listify_application/models/auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithGoogle() async {
    // 1) Kullanıcı Google hesabını seçer
    final gUser = await GoogleSignIn().signIn();
    if (gUser == null) {
      throw Exception('Google sign-in canceled');
    }
    final gAuth = await gUser.authentication;

    // 2) Firebase credential
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    // 3) Firebase sign-in
    return await _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signUpWithEmail(Auth auth) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: auth.email,
      password: auth.password,
    );
    return credential;
  }

  Future<UserCredential> signInWithEmail(Auth auth) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: auth.email,
      password: auth.password,
    );
    return credential;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() => _auth.signOut();
}
