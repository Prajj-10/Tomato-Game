import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../game_interface/play_game.dart';

class Navigation extends StatelessWidget {
  const Navigation({super.key});
// The whole purpose of navigation is to navigate to respective page depending if the user is logged in or not.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Text("Something went Wrong !!"),
            );
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
