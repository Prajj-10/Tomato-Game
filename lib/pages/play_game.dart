import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:tomato_game/Custom_Widgets/custom_button.dart';
import 'package:tomato_game/pages/login_page.dart';
import 'package:tomato_game/pages/play_options.dart';

import '../custom_widgets/custom_loading.dart';
import '../google_authentication/google_sign_in.dart';
import '../models/user_model.dart';
import 'navigation.dart';

class PlayGame extends StatefulWidget {
  const PlayGame({super.key});

  @override
  State<PlayGame> createState() => _PlayGameState();
}

class _PlayGameState extends State<PlayGame> {
  // To get name from Firebase Firestore.
  var name;

  // User Model to map data.
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  @override
  void initState() {
    // Called these functions when loading the page.
    getDetails();
    loggedIn();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => Container(
            decoration: BoxDecoration(
              color: Color(0xF29F9F).withOpacity(0.9),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              child: new AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 10,
                title: new Text(
                  'Exit App',
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Electronic Highway Sign',
                      //color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                content: new Text(
                  'Are you sure you want to exit the App?',
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Electronic Highway Sign',
                      //color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: new Text(
                      'No',
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Electronic Highway Sign',
                          //color: Color(0xF29F9F).withOpacity(0.9),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: new Text(
                      'Yes',
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Electronic Highway Sign',
                          //color: Color(0xF29F9F).withOpacity(0.9),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    // Phone Size
    var size = MediaQuery.of(context).size;
    // Ternary Operator to check if user is logged in or not.
    bool loggedIn = (name != null) ? true : false;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            height: size.height,
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [
                // Linear Gradient Colours
                const Color(0xF29F9F).withOpacity(0.9),
                const Color(0xFAFAFA).withOpacity(1.0),
              ],
              // Gradient Colour patterns
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )),
            //color: Colors.white,
            padding: const EdgeInsets.all(36.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Tomato Game",
                  style: TextStyle(
                      fontSize: 50,
                      fontFamily: 'Electronic Highway Sign',
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 25,
                ),
                SizedBox(
                  height: 200,
                  child: Image.asset(
                    "assets/images/tomato-spin.gif",
                    fit: BoxFit.contain,
                  ), // Image location
                ),
                const SizedBox(
                  height: 30,
                ),
                Center(
                  child: loggedIn
                      ? Text(
                          "Welcome $name",
                          style: TextStyle(
                              fontFamily: 'Electronic Highway Sign',
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        )
                      : const Text(""),
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomButton(
                  text: 'Play',
                  onTap: () {
                    if (name == null) {
                      AnimatedSnackBar.material(
                              "Please Login with an account to play the game.",
                              type: AnimatedSnackBarType.error,
                              mobileSnackBarPosition:
                                  MobileSnackBarPosition.top)
                          .show(context);
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PlayOptions()));
                    }
                    // playGame();
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomButton(
                  text: 'Exit',
                  onTap: () {
                    // Function
                    exit(0);
                  },
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        "Press ",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Electronic Highway Sign'),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()));
                        },
                        child: Text(
                          "here ",
                          style: TextStyle(
                              color: Color(0xF29F9F).withOpacity(1.0),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              fontFamily: 'Electronic Highway Sign'),
                        ),
                      ),
                      const Text(
                        "to go the the Login Page.",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Electronic Highway Sign'),
                      ),
                    ]),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    _showLogoutDialog();
                    //logout(context);
                  },
                  child: Text(
                    "Logout? ",
                    style: TextStyle(
                        color: Color(0xF29F9F).withOpacity(1.0),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'Electronic Highway Sign'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Returns a bool value if the user is logged in or not.
  bool loggedIn() {
    if (name != null) {
      return true;
    } else {
      return false;
    }
  }

  // Gets details from the Firebase if the user is already logged in.
  void getDetails() async {
    var userDetails = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();

    setState(() {
      name = userDetails.data()!['name'];
    });
  }

  void _showLogoutDialog() {
    if (name != null) {
      showDialog(
        context: context,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              color: Color(0xF29F9F).withOpacity(0.9),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 10,
                title: Container(
                  child: const Text(
                    "Log Out",
                    style: TextStyle(
                        fontFamily: 'Electronic Highway Sign',
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
                content: Text(
                  "Are you sure you want to logout?",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Electronic Highway Sign'),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      // Close the dialog
                      Navigator.pop(context);

                      // You can implement logic to restart the game here.
                      logout(context);
                    },
                    child: const Text(
                      "Yes",
                      style: TextStyle(
                          fontFamily: 'Electronic Highway Sign',
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Close the dialog
                      Navigator.pop(context);

                      // You can implement logic to navigate to the home screen here.
                    },
                    child: const Text(
                      "No",
                      style: TextStyle(
                          fontFamily: 'Electronic Highway Sign',
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      Text("User Not logged in");
      AnimatedSnackBar.material(
        "No user is logged in.",
        type: AnimatedSnackBarType.error,
        //duration: const Duration(milliseconds: 1700),
        mobilePositionSettings: const MobilePositionSettings(
          topOnAppearance: 100,
        ),
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    var provider = Provider.of<GoogleSignInProvider>(context, listen: false);
    print(provider.googleSignIn.currentUser);
    if (provider.googleSignIn.currentUser != null) {
      SmartDialog.showLoading(
        builder: (_) => CustomLoading(type: 2),
        maskColor: Color(0xF29F9F).withOpacity(1.0),
        animationType: SmartAnimationType.scale,
        //msg: "Loading",
        backDismiss: false,
      );
      // Clears the cache of the user
      await provider.googleSignIn.currentUser?.clearAuthCache();
      await provider.googleSignIn.disconnect();
      // Signs out from google
      await FirebaseAuth.instance.signOut();
      await provider.googleSignIn.signOut();
    } else {
      SmartDialog.showLoading(
        builder: (_) => CustomLoading(type: 2),
        maskColor: Color(0xF29F9F).withOpacity(1.0),
        animationType: SmartAnimationType.scale,
        //msg: "Loading",
        backDismiss: false,
      );
      // Signs out from email/ password
      await FirebaseAuth.instance.signOut();
    }
    SmartDialog.dismiss();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Navigation()));
    AnimatedSnackBar.material(
      "Logged Out Sucessfully.",
      type: AnimatedSnackBarType.success,
      duration: const Duration(milliseconds: 1700),
      mobilePositionSettings: const MobilePositionSettings(
        topOnAppearance: 100,
      ),
    );
  }
}
