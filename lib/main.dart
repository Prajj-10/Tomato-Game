import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tomato_game/google_authentication/google_sign_in.dart';
import 'package:tomato_game/pages/navigation.dart';
import 'package:tomato_game/services/firebase_options.dart';

Future<void> main() async {
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
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => GoogleSignInProvider(),
        child: MaterialApp(
          title: 'Tomato Game',
          theme: ThemeData(
            primarySwatch: Colors.pink,
          ),
          debugShowCheckedModeBanner: false,
          home: const Navigation(),
        ),
      );
}
