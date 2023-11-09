import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:tomato_game/pages/play_game.dart';

import '../Custom_Widgets/custom_button.dart';
import '../models/api_model.dart';
import '../models/user_model.dart';
import 'navigation.dart';

class ClassicGame extends StatefulWidget {
  const ClassicGame({super.key});

  @override
  State<ClassicGame> createState() => _ClassicGameState();
}

class _ClassicGameState extends State<ClassicGame> {
  int score = 0;
  int round = 1;

  final googleSignIn = GoogleSignIn();

  final _formKey = GlobalKey<FormState>();

  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  late Future<QuestionAnswer?>? _futurequestion;
  TextEditingController ansController = TextEditingController();

  List<QuestionAnswer> questionAnswer = [];

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
    initfuture();
  }

  initfuture() {
    _futurequestion = getData();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Color(0xF29F9F).withOpacity(0.9),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.skip_next_sharp),
              color: Colors.red,
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.help_outline_sharp),
              color: Colors.red,
            ),
          ],
          // title: const Text("Tomato Game"),
          leading: IconButton(
            color: Colors.red,
            onPressed: () {
              logout(context);
            },
            icon: const Icon(Icons.logout_outlined),
          )),
      body: //future builder
          Container(
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
        child: FutureBuilder<QuestionAnswer?>(
            future: _futurequestion,
            builder: (BuildContext context,
                AsyncSnapshot<QuestionAnswer?> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Container(
                    child: Text(
                      "Could not establish Connection.",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Electronic Highway Sign'),
                    ),
                  ); // error//
                case ConnectionState.waiting: //loading
                  return const Center(
                      child: SizedBox(
                    height: 50,
                    width: 50,
                    child: Center(child: CircularProgressIndicator()),
                  ));
                case ConnectionState.done:
                  if (snapshot.data == null) {
                    return Center(
                        child: const Text(
                      "Could not fetch data from the API.",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Electronic Highway Sign'),
                    )); // no data
                  } else {
                    //ui
                    return Padding(
                      padding: const EdgeInsets.all(36.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Text("Welcome ${loggedInUser.name!}"),
                            /*const SizedBox(
                                  height: 20,
                                ),*/
                            Row(
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "Round: $round",
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Electronic Highway Sign'),
                                  ),
                                ),
                                const SizedBox(
                                  width: 160,
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    "Score : $score",
                                    //textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Electronic Highway Sign'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 80,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: const Text(
                                "Enter the correct number: ",
                                //textAlign: TextAlign.,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Electronic Highway Sign'),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: Image.network(
                                questionAns!.question,
                                width: 400,
                                height: 250,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Center(
                                child: Form(
                              key: _formKey,
                              child: TextFormField(
                                controller: ansController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Enter a value",
                                  hintStyle: TextStyle(
                                      fontFamily: 'Electronic Highway Sign',
                                      fontWeight: FontWeight.bold),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  int? enteredValue = int.tryParse(value);
                                  if (enteredValue != null) {
                                    ansController.text =
                                        enteredValue.toString();
                                  }
                                },
                                style: const TextStyle(fontSize: 15),
                              ),
                            )),
                            const SizedBox(
                              height: 25,
                            ),
                            Center(
                                child: CustomButton(
                              onTap: () {
                                checkAnswer();
                                //ansController.clear();
                              },
                              text: 'Enter',
                            )),
                          ],
                        ),
                      ),
                    );
                  }
                default:
                  return Container(); //error page
              }
            }),
      ),
    );
  }

  QuestionAnswer? questionAns;
  Future<QuestionAnswer?> getData() async {
    try {
      String url = "https://marcconrad.com/uob/tomato/api.php";
      http.Response res = await http.get(Uri.parse(url));
      questionAns = QuestionAnswer.fromJson(json.decode(res.body));
      return questionAns;
    } catch (e) {
      return null;
      //  debugPrint(e.toString());
    }
  }

  // Logs out user from the account.
  Future<void> logout(BuildContext context) async {
    await googleSignIn.currentUser?.clearAuthCache();
    await FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();
    AnimatedSnackBar.material(
      "Logged Out Sucessfully.",
      type: AnimatedSnackBarType.success,
      duration: const Duration(milliseconds: 1700),
      mobilePositionSettings: const MobilePositionSettings(
        topOnAppearance: 100,
        // topOnDissapear: 50,
        // bottomOnAppearance: 100,
        //bottomOnDissapear: 50,
        // left: 20,
        // right: 70,
      ),
    );
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Navigator()));
    // Fluttertoast.showToast(msg: "Logged Out Successfully.");
  }

  // Checks answer with the api value.

  Future<void> checkAnswer() async {
    int value = int.tryParse(ansController.text) ?? 0; // Default sets to 0.
    if (value == questionAns!.solution) {
      QuestionAnswer? newQuestion = await getData();
      AnimatedSnackBar.material(
        "Correct Answer",
        type: AnimatedSnackBarType.success,
        duration: const Duration(milliseconds: 1700),
        mobilePositionSettings: const MobilePositionSettings(
          topOnAppearance: 100,
          // topOnDissapear: 50,
          // bottomOnAppearance: 100,
          //bottomOnDissapear: 50,
          // left: 20,
          // right: 70,
        ),
      ).show(context);
      setState(() {
        questionAns = newQuestion;
        ansController.clear(); // Clear the input field
        score++;
        round++;
        finishRounds();
      });

      // refreshData();
      //Fluttertoast.showToast(msg: "Correct Answer");
    } else {
      AnimatedSnackBar.material(
        "Wrong Answer",
        type: AnimatedSnackBarType.error,
        duration: const Duration(milliseconds: 1700),
        mobilePositionSettings: const MobilePositionSettings(
          topOnAppearance: 100,
          //topOnDissapear: 50,
          // bottomOnAppearance: 100,
          // bottomOnDissapear: 50,
          // left: 20,
          // right: 70,
        ),
      ).show(context);
      setState(() {
        ansController.clear();
      });

      // Fluttertoast.showToast(msg: "Wrong Answer");
    }
  }

  // Is called when the game needs to be restarted.

  void _restartGame() {
    // You can reset the game state, including score, timer, and other relevant data.
    setState(() {
      score = 0;
      round = 1; // Reset the timer to the initial time
    });
  }

  // Is used to check how many number of rounds have elapsed.

  void finishRounds() {
    if (round == 10) {
      _showGameOverDialog();
    }
  }

  // Function to navigate to the home screen
  void _navigateToHomeScreen() {
    // You can use Navigator to navigate to the home screen or any other desired screen.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const Navigation()), // Replace "HomeScreen" with your actual home screen widget.
    );
  }

  // Function that shows the game over dialog.
  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          //height: MediaQuery.of(context).size.width,
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
                //color: Color(0xF29F9F).withOpacity(0.9),
                //height: MediaQuery.of(context).size.height / 6,
                child: const Text(
                  "Game Over",
                  style: TextStyle(
                      fontFamily: 'Electronic Highway Sign',
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
              content: Text(
                "Your final score: $score",
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
                    _restartGame();
                  },
                  child: const Text(
                    "Play Again",
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
                    _navigateToHomeScreen();
                  },
                  child: const Text(
                    "Return to Main Screen",
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
  }
}
