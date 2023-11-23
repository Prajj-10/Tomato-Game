import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tomato_game/game_modes/classic_game.dart';
import '../../Custom_Widgets/custom_button.dart';
import '../../game_modes/time_challenge.dart';
import '../../models/user_model.dart';

class PlayOptions extends StatefulWidget {
  const PlayOptions({super.key});

  @override
  State<PlayOptions> createState() => _PlayOptionsState();
}

class _PlayOptionsState extends State<PlayOptions> {
  // Name is only created to make sure if the user is still logged in or not.
  var name;

  // User Model to map data from Fire store.
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  @override
  void initState() {
    // Getting details as the page is being loaded.
    getDetails();
  }

  @override
  Widget build(BuildContext context) {
    // Phone Size
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [
              // Gradient of the page.
              const Color(0xF29F9F).withOpacity(0.9),
              const Color(0xFAFAFA).withOpacity(1.0),
            ],
            // Gradient Pattern
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
                "Select Options",
                style: TextStyle(
                    fontSize: 48,
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
              CustomButton(
                text: 'Classic',
                onTap: () {
                  // Function
                  if (name == null) {
                    AnimatedSnackBar.material("Login Error",
                            type: AnimatedSnackBarType.error,
                            mobileSnackBarPosition: MobileSnackBarPosition.top)
                        .show(context);
                  } else {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ClassicGame()));
                  }
                },
              ),
              SizedBox(
                height: 20,
              ),
              CustomButton(
                  onTap: () {
                    // Function
                    if (name == null) {
                      AnimatedSnackBar.material("Login Error",
                              type: AnimatedSnackBarType.error,
                              mobileSnackBarPosition:
                                  MobileSnackBarPosition.top)
                          .show(context);
                    } else {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TimeChallengeGame()));
                    }
                  },
                  text: 'Time Challenge')
            ],
          ),
        ),
      ),
    );
  }

  // Getting details of the user from Firebase
  void getDetails() async {
    var userDetails = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();

    setState(() {
      name = userDetails.data()!['name'];
    });
  }
}
