import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../custom_widgets/custom_snackbar.dart';

class FirebaseAuthMethods {
  final FirebaseAuth _auth;
  FirebaseAuthMethods(this._auth);

  // Email SignUp
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // if you want to display your own custom error message
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      showSnackBar(
          context, e.message!); // Displaying the usual firebase error message
    }
  }
}
