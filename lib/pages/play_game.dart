import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tomato_game/Custom_Widgets/custom_button.dart';
import 'package:tomato_game/pages/home_page.dart';
import 'package:tomato_game/pages/login_page.dart';

import '../models/user_model.dart';

class PlayGame extends StatefulWidget {
  const PlayGame({super.key});

  @override
  State<PlayGame> createState() => _PlayGameState();
}

class _PlayGameState extends State<PlayGame> {
  var name;

  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  void getDetails() async {
    //final user = await FirebaseAuth.instance.currentUser;
    //UserModel loggedInUser = UserModel();
    //CookingStepsModel recipeList = new CookingStepsModel();
    var userDetails = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();

    setState(() {
      name = userDetails.data()!['name'];
    });
  }

  @override
  void initState() {
    getDetails();
    loggedIn();
  }

  bool loggedIn() {
    if (name != null) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    bool loggedIn = (name != null) ? true : false;
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [
              const Color(0xF29F9F).withOpacity(0.9),
              const Color(0xFAFAFA).withOpacity(1.0),
            ],
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
                            mobileSnackBarPosition: MobileSnackBarPosition.top)
                        .show(context);
                  } else {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage()));
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
                  ])
            ],
          ),
        ),
      ),
    );
  }
  /*void getData() async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
    });
  }*/
}
