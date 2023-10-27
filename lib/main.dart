import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tomato_game/firebase_options.dart';
import 'package:tomato_game/login_page.dart';

import 'home_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: const LoginScreen(),
      ),
    );
  }
}

