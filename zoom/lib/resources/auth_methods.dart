import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../utils/utils.dart';

class AuthModel {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Stream<User?> get authChanges => _firebaseAuth.authStateChanges();

  User get user => _firebaseAuth.currentUser!;

  Future<String> userLogin(String email, String password) async {
    var res = "Error occurred";
    try {
      if (email.isEmpty) {
        return res = "Please enter valid email id";
      }
      if (password.isEmpty) {
        return res = "Please enter valid password";
      }
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      res = "success";
    } catch (error) {
      res = error.toString();
      if (kDebugMode) {
        print(error);
      }
    }
    return res;
  }

  Future<bool> signInWithGoogle(BuildContext context) async {
    bool res = false;
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        if (userCredential.additionalUserInfo!.isNewUser) {
          await _firebaseFirestore.collection('users').doc(user.uid).set({
            'username': user.displayName,
            'uid': user.uid,
            'profilePhoto': user.photoURL
          });
        }
        res = true;
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
      res = false;
    }
    return res;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
