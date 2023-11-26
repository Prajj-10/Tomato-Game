import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../custom_widgets/custom_snackbar.dart';

/// A class that encapsulates Firebase Authentication methods.
///
/// This class provides methods for common authentication operations using
/// Firebase Authentication, such as signing up with email and password.
class FirebaseAuthMethods {
  /// The Firebase Authentication instance used for authentication operations.
  final FirebaseAuth _auth;

  /// Creates a [FirebaseAuthMethods] instance.
  ///
  /// The [auth] parameter must not be null.
  FirebaseAuthMethods(this._auth);

  /// Signs up a user with email and password.
  ///
  /// Parameters:
  /// - [email]: The email address of the user.
  /// - [password]: The password for the user.
  /// - [context]: The build context associated with the current widget tree.
  ///
  /// Throws a [FirebaseAuthException] if the sign-up process fails. Displays
  /// an error message using the [showSnackBar] function in case of failure.
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
