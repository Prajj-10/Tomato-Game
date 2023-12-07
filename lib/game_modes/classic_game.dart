import 'dart:async';
import 'dart:convert';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../Custom_Widgets/custom_button.dart';
import '../google_authentication/google_sign_in.dart';
import '../models/api_model.dart';
import '../models/user_model.dart';
import '../navigation_handler/navigation.dart';

/// The screen for the Classic Game mode.
class ClassicGame extends StatefulWidget {
  const ClassicGame({super.key});

  @override
  State<ClassicGame> createState() => _ClassicGameState();
}

class _ClassicGameState extends State<ClassicGame> {
  /// Initial Score and Round of the user.
  int score = 0;
  int round = 1;

  late Timer _countdownTimer;
  int _countdown = 3;

  /// Google Sign-In object.
  final googleSignIn = GoogleSignIn();

  /// Form Key for validation.
  final _formKey = GlobalKey<FormState>();

  /// User Model for data extraction
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  /// Future of the API function.
  late Future<QuestionAnswer?>? _futurequestion;
  TextEditingController ansController = TextEditingController();

  /// A list to get data from the API.
  List<QuestionAnswer> questionAnswer = [];

  @override
  void initState() {
    super.initState();

    /// Firebase is initialized at first for data.
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      startCountdown();
    });

    /// Function of the API.
    initfuture();
  }

  initfuture() {
    _futurequestion = getData();
  }

  @override
  Widget build(BuildContext context) {
    /// Phone Size
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        /// Main Background
        backgroundColor: Color(0xF29F9F).withOpacity(0.9),

        /// Top Bar
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Color(0xF29F9F).withOpacity(0.9),
          actions: [
            IconButton(
              onPressed: () {
                _skipQuestion();
              },
              icon: Icon(Icons.skip_next_sharp),
              color: Colors.red,
            ),
            IconButton(
              onPressed: () {
                _showHowToPlay();
              },
              icon: Icon(Icons.help_outline_sharp),
              color: Colors.red,
            ),
          ],
        ),
        body: //future builder
            Container(
          height: size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [
              /// Gradient present in the page.
              const Color(0xF29F9F).withOpacity(0.9),
              const Color(0xFAFAFA).withOpacity(1.0),
            ],

            /// Flow of the Gradient colour.
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )),

          /// Future Builder to handle the call of the API.
          child: Stack(
            children: [
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

                          /// Loading Screen
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
                          ));

                          /// no data
                        } else {
                          ///Main UI.
                          return Padding(
                            padding: const EdgeInsets.all(36.0),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          "Round: $round",
                                          style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              fontFamily:
                                                  'Electronic Highway Sign'),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 140,
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
                                          fontFamily:
                                              'Electronic Highway Sign'),
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
                                            fontFamily:
                                                'Electronic Highway Sign',
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
              _countdown == 0
                  ? Container()
                  : Positioned(
                      top: 0,
                      left: 0,
                      child: GestureDetector(
                        onTap: () {
                          //do nothing
                        },
                        child: Container(
                            height: size.height,
                            width: size.width,
                            color: Color(0xF29F9F).withOpacity(0.95),
                            child: Center(
                                child: Text(_countdown.toString(),
                                    style: TextStyle(fontSize: 60)))),
                      ))
            ],
          ),
        ),
      ),
    );
  }

  /// Other methods, such as startCountdown, getData, checkAnswer, _skipQuestion, _onWillPop, _navigateToHomeScreen, _showGameOverDialog, _showHowToPlay, _saveScore, and highscore.

  void startCountdown() {
    const oneSecond = Duration(seconds: 1);
    _countdownTimer = Timer.periodic(oneSecond, (timer) {
      setState(() {
        if (_countdown >= 1) {
          _countdown--;
        } else {
          /// If the countdown is finished, cancel the timer and start the game
          _countdownTimer.cancel();
        }
      });
    });
  }

  /// Main function of the API too get data.
  QuestionAnswer? questionAns;
  Future<QuestionAnswer?> getData() async {
    try {
      String url = "https://marcconrad.com/uob/tomato/api.php";
      http.Response res = await http.get(Uri.parse(url));
      questionAns = QuestionAnswer.fromJson(json.decode(res.body));
      print(questionAns?.solution);
      return questionAns;
    } catch (e) {
      return null;
      //  debugPrint(e.toString());
    }
  }

  /// Logs out user from the account.

  Future<void> logout(BuildContext context) async {
    final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
    print(provider.googleSignIn.currentUser);
    if (provider.googleSignIn.currentUser != null) {
      /// Clears the cache of the user
      await provider.googleSignIn.currentUser?.clearAuthCache();
      await provider.googleSignIn.disconnect();

      /// Signs out from google
      await FirebaseAuth.instance.signOut();
      await provider.googleSignIn.signOut();
    } else {
      /// Signs out from email/ password
      await FirebaseAuth.instance.signOut();
    }
    AnimatedSnackBar.material(
      "Logged Out Sucessfully.",
      type: AnimatedSnackBarType.success,
      duration: const Duration(milliseconds: 1700),
      mobilePositionSettings: const MobilePositionSettings(
        topOnAppearance: 100,
      ),
    );
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Navigation()));
  }

  /// Checks answer with the api value.

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
        ),
      ).show(context);
      setState(() {
        questionAns = newQuestion;
        ansController.clear(); // Clear the input field
        score += 5;
        round++;
      });
      finishRounds();

      /// refreshData();
    } else {
      AnimatedSnackBar.material(
        "Wrong Answer",
        type: AnimatedSnackBarType.error,
        duration: const Duration(milliseconds: 1700),
        mobilePositionSettings: const MobilePositionSettings(
          topOnAppearance: 100,
        ),
      ).show(context);
      setState(() {
        score -= 2;
        ansController.clear();
      });

      // Fluttertoast.showToast(msg: "Wrong Answer");
    }
  }

  /// Is called when the game needs to be restarted.

  void _restartGame() {
    /// Reset the game state, including score, timer, and other relevant data.
    setState(() {
      score = 0;
      round = 1; // Reset the timer to the initial time
    });
  }

  /// Is used to check how many number of rounds have elapsed.

  void finishRounds() {
    if (round >= 10) {
      _saveScore();
      _showGameOverDialog();
    }
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
                  'Are you sure you want to quit?',
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Electronic Highway Sign',
                      //color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                content: new Text(
                  'Your current score will not be saved if you quit now.',
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

  /// Function to navigate to the home screen
  void _navigateToHomeScreen() {
    /// You can use Navigator to navigate to the home screen or any other desired screen.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const Navigation()), // Replace "HomeScreen" with your actual home screen widget.
    );
  }

  /// Function that shows the game over dialog.
  void _showGameOverDialog() {
    bool highscore =
        (score >= loggedInUser.highestScoreClassic!) ? true : false;
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
                  "Game Over",
                  style: TextStyle(
                      fontFamily: 'Electronic Highway Sign',
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Your final score: $score",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Electronic Highway Sign'),
                  ),
                  Center(
                      child: highscore
                          ? Text(
                              'Your high score : $score',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Electronic Highway Sign'),
                            )
                          : Text(
                              "Your high score : ${loggedInUser.highestScoreClassic}",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Electronic Highway Sign'),
                            )),
                ],
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

  /// How to play Dialog Option.

  void _showHowToPlay() {
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
                  "How to Play: ",
                  style: TextStyle(
                      fontFamily: 'Electronic Highway Sign',
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
              content: Text(
                "1.) Enter the missing number in the image.\n\n"
                "2.) You have 10 rounds in total.\n\n"
                "3.) If you enter the correct answer, you score 5 points.\n\n"
                "4.) For every wrong answer, 2 points are deducted.\n\n"
                "5.) You can skip the question but this skips the rounds.\n\n"
                "\n"
                "Let's start from the beginning.\n\n"
                "All the best !",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Electronic Highway Sign'),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    /// Close the dialog
                    Navigator.pop(context);

                    // You can implement logic to restart the game here.
                    setState(() {
                      score = 0;
                      round = 1; // Reset the timer to the initial time
                    });
                  },
                  child: const Text(
                    "Okay",
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

  Future<void> _skipQuestion() async {
    QuestionAnswer? newQuestion = await getData();
    setState(() {
      questionAns = newQuestion;
      ansController.clear();

      /// Clear the input field
      round++;
    });
    finishRounds();
  }

  bool highscore() {
    if (score >= loggedInUser.highestScoreClassic!) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _saveScore() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
    });
    if (loggedInUser.highestScoreClassic == null) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser?.uid)
          .set({'highest_score_classic': 0}, SetOptions(merge: true));
    }
    if (score >= loggedInUser.highestScoreClassic!) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser?.uid)
          .set({'highest_score_classic': score}, SetOptions(merge: true));
    }
  }
}
