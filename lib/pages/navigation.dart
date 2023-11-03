import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tomato_game/pages/home_page.dart';
import 'package:tomato_game/pages/login_page.dart';

class Navigation extends StatelessWidget {
  const Navigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.hasError){
            return const Center(child: CircularProgressIndicator());
          }
          if(snapshot.connectionState == ConnectionState.waiting ){
            return const Center(child: Text("Something went Wrong !!"),);
          }
          else if(snapshot.hasData){
            var user = FirebaseAuth.instance.currentUser;
            return const HomePage();
          }
          else{
            return const LoginScreen();
          }
        },
      ),
    );
  }
}

