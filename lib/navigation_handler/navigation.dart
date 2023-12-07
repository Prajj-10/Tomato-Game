import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../game_interface/play_game.dart';

/// The [Navigation] widget is responsible for navigating to the respective page
/// depending on whether the user is logged in or not.
class Navigation extends StatelessWidget {
  /// Default constructor for the [Navigation] widget.
  const Navigation({Key? key});

  /// The build method for constructing the UI of the [Navigation] widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went Wrong !!"),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            var user = FirebaseAuth.instance.currentUser;
            return const PlayGame();
          } else {
            return const PlayGame();
          }
        },
      ),
    );
  }
}
