import 'dart:async';
import 'dart:convert';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:tomato_game/Custom_Widgets/custom_button.dart';
import 'package:tomato_game/pages/play_game.dart';
import '../models/api_model.dart';
import '../models/user_model.dart';
import 'navigation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int score = 0; // Initialize the score
  late Timer _gameTimer;
  int _timeLeft = 60; // Set the initial time in seconds

  final _formKey = GlobalKey<FormState>();

  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  final googleSignIn = GoogleSignIn();

  late Future<QuestionAnswer?>? _futurequestion;
  TextEditingController ansController = TextEditingController();

  // bool _isLoading = true;
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
    _startGameTimer();
  }

  initfuture() {
    _futurequestion = getData();
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

  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _gameTimer.cancel();
          _showGameOverDialog();
          // Implement logic to end the game here (e.g., show a game-over screen).
        }
      });
    });
  }

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
        MaterialPageRoute(builder: (context) => const PlayGame()));
    // Fluttertoast.showToast(msg: "Logged Out Successfully.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          // title: const Text("Tomato Game"),
          leading: IconButton(
            color: Colors.red,
            onPressed: () {
              logout(context);
            },
            icon: const Icon(Icons.logout_outlined),
          )),
      body: //future builder
          FutureBuilder<QuestionAnswer?>(
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
                                      "Time: $_timeLeft seconds",
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          fontFamily:
                                              'Electronic Highway Sign'),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 75,
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Text(
                                      "Score : $score",
                                      //textAlign: TextAlign.start,
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          fontFamily:
                                              'Electronic Highway Sign'),
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
    );
  }

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
        _timeLeft += 5;
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
        _timeLeft -= 1;
      });

      // Fluttertoast.showToast(msg: "Wrong Answer");
    }
  }

  // Function to restart the game
  void _restartGame() {
    // You can reset the game state, including score, timer, and other relevant data.
    setState(() {
      score = 0;
      _timeLeft = 60; // Reset the timer to the initial time
    });

    // Start the game timer again
    _startGameTimer();
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

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Game Over",
            style: TextStyle(
                fontFamily: 'Electronic Highway Sign',
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          content: Text(
            "Your final score: $score",
            style: TextStyle(
                fontSize: 16,
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
                    fontSize: 14),
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
                    fontSize: 14),
              ),
            ),
          ],
        );
      },
    );
  }
}
