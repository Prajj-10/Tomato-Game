import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

/// A provider class for managing Google Sign-In functionality and user authentication.
class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();
  final usersRef = FirebaseFirestore.instance.collection('users');

  GoogleSignInAccount? _user;

  /// Gets the current Google user account.
  GoogleSignInAccount get user => _user!;

  /// Logs in the user with Google authentication.
  Future googleLogin() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      _user = googleUser;

      final googleAuth = await googleUser.authentication;

      // Creates the credential
      final credential = GoogleAuthProvider.credential(
        // Creates access and id token.
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }

    notifyListeners();
    createUserInFirestore();
  }

  /// Logs out the user.
  Future logout() async {
    await googleSignIn.currentUser?.clearAuthCache();
    await FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();
  }

  /// Creates a user in Firestore if it doesn't exist.
  createUserInFirestore() async {
    // check if the user exists in the users collection.
    final GoogleSignInAccount? user = googleSignIn.currentUser;
    final currentUser = FirebaseAuth.instance.currentUser;
    final DocumentSnapshot doc = await usersRef.doc(currentUser?.uid).get();

    if (!doc.exists) {
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

      // call user model
      UserModel userModel = UserModel();

      // writing all values
      userModel.uid = currentUser?.uid;
      userModel.name = user?.displayName;
      userModel.email = user?.email;

      await firebaseFirestore
          .collection("users")
          .doc(currentUser?.uid)
          .set(userModel.toMap(), SetOptions(merge: true));
    }
  }
}
