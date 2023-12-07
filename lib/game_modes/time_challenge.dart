import 'dart:async';
import 'dart:convert';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tomato_game/Custom_Widgets/custom_button.dart';
import '../google_authentication/google_sign_in.dart';
import '../models/api_model.dart';
import '../models/user_model.dart';
import '../navigation_handler/navigation.dart';

/// The screen for the Time Challenge Game mode.
class TimeChallengeGame extends StatefulWidget {
  const TimeChallengeGame({super.key});

  @override
  State<TimeChallengeGame> createState() => _TimeChallengeGameState();
}

/// The state of the [TimeChallengeGame] widget.
class _TimeChallengeGameState extends State<TimeChallengeGame> {
  /// The current score of the player.
  int score = 0;

  /// Timer for the main game.
  late Timer _gameTimer;

  /// The time left in seconds for the game.
  int _timeLeft = 120;

  /// Timer for the countdown before the game starts.
  late Timer _countdownTimer;

  /// The countdown value before the game starts.
  int _countdown = 3;

  /// GlobalKey for form validation.
  final _formKey = GlobalKey<FormState>();

  /// User Model for data extraction.
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  /// Google Sign-In object.
  final googleSignIn = GoogleSignIn();

  /// Future variable to get data from the API.
  late Future<QuestionAnswer?>? _futurequestion;

  /// Controller for the answer input field.
  TextEditingController ansController = TextEditingController();

  /// List to store the fetched question and answer.
  List<QuestionAnswer> questionAnswer = [];

  @override
  void initState() {
    super.initState();

    /// Initialize Firebase and get data for the logged-in user.
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

    initfuture();
  }

  /// Initialize the future for fetching data from the API.
  initfuture() {
    _futurequestion = getData();
  }

  @override
  Widget build(BuildContext context) {
    // Get the phone size.
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
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
        body: Container(
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
            ),
          ),
          child: Stack(
            children: [
              FutureBuilder<QuestionAnswer?>(
                future: _futurequestion,
                builder: (BuildContext context,
                    AsyncSnapshot<QuestionAnswer?> snapshot) {
                  // Managing Data depending on what is received from the API.
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
                        ),
                      );
                    case ConnectionState.done:
                      if (snapshot.data == null) {
                        return Center(
                          child: const Text(
                            "Could not fetch data from the API.",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Electronic Highway Sign'),
                          ),
                        ); // no data
                      } else {
                        //UI if the data is present
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
                                        "Time: $_timeLeft seconds",
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Electronic Highway Sign',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 63,
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Text(
                                        "Score : $score",
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Electronic Highway Sign',
                                        ),
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
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Electronic Highway Sign',
                                    ),
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
                                          fontWeight: FontWeight.bold,
                                        ),
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
                                  ),
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                Center(
                                  child: CustomButton(
                                    onTap: () {
                                      checkAnswer(); // Function to check ans being called
                                    },
                                    text: 'Enter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    default:
                      return Container(); //error page
                  }
                },
              ),
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
                            child: Text(
                              _countdown.toString(),
                              style: TextStyle(fontSize: 60),
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  /// The main function that is being called to get data from API.
  QuestionAnswer? questionAns;

  /// Fetches question and answer data from the API.
  ///
  /// Returns a [QuestionAnswer] object if successful, otherwise returns null.
  Future<QuestionAnswer?> getData() async {
    try {
      String url = "https://marcconrad.com/uob/tomato/api.php";
      http.Response res = await http.get(Uri.parse(url));
      questionAns = QuestionAnswer.fromJson(json.decode(res.body));
      print(questionAns?.solution);
      return questionAns;
    } catch (e) {
      return null;
    }
  }

  /// Starts the game timer and shows the Game over dialog when the time is over.
  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _gameTimer.cancel();
          _saveScore();
          _showGameOverDialog();
        }
      });
    });
  }

  /// Logs the user out from their account.
  Future<void> logout(BuildContext context) async {
    final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
    print(provider.googleSignIn.currentUser);
    if (provider.googleSignIn.currentUser != null) {
      // Clears the cache of the user
      await provider.googleSignIn.currentUser?.clearAuthCache();
      await provider.googleSignIn.disconnect();
      // Signs out from google
      await FirebaseAuth.instance.signOut();
      await provider.googleSignIn.signOut();
    } else {
      // Signs out from email/ password
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

  /// Checks for answer if it's correct or not.
  ///
  /// If the entered value matches the correct solution, updates the score
  /// and fetches a new question. Otherwise, updates the time and score accordingly.
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
        score += 2;
        _timeLeft += 10;
      });
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
        ansController.clear();
        _timeLeft -= 2;
      });
    }
  }

  /// Restarts the game by resetting the score, timer, and other relevant data.
  void _restartGame() {
    setState(() {
      score = 0;
      _timeLeft = 120; // Reset the timer to the initial time
    });
    // Starts the game again.
    _startGameTimer();
  }

  /// Navigates to the home screen.
  void _navigateToHomeScreen() {
    // Navigator to navigate to the home screen or any other desired screen.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Navigation()),
    );
  }

  /// Handles the back button press and shows a confirmation dialog.
  ///
  /// Returns true if the user confirms to exit, otherwise returns false.
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

  /// Checks if the current score is a new high score.
  ///
  /// Returns true if the score is greater than or equal to the user's highest score,
  /// otherwise returns false.
  bool highscore() {
    if (score >= loggedInUser.highestScore!) {
      return true;
    } else {
      return false;
    }
  }

  /// Shows the game over dialog with the final score.
  void _showGameOverDialog() {
    // Ternary Operator Magic
    bool highscore = (score >= loggedInUser.highestScore!) ? true : false;
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
                              "Your high score : ${loggedInUser.highestScore}",
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

  /// Shows the how-to-play dialog with game instructions.
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
                "2.) You have 120 seconds (2 minutes) in total.\n\n"
                "3.) If you enter the correct answer, 10 seconds is added and the score is 2 points.\n\n"
                "4.) For every wrong answer, 2 seconds is deducted and 1 point is deducted.\n\n"
                "5.) You can skip the question if you want but this deducts 5 seconds.\n\n"
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
                    // Close the dialog
                    Navigator.pop(context);

                    // You can implement logic to restart the game here.
                    setState(() {
                      score = 0;
                      _timeLeft = 120; // Reset the timer to the initial time
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

  /// Skips the current question and deducts 5 seconds from the timer.
  Future<void> _skipQuestion() async {
    QuestionAnswer? newQuestion = await getData();
    setState(() {
      questionAns = newQuestion;
      ansController.clear(); // Clear the input field
      _timeLeft -= 5;
    });
  }

  /// Starts the countdown before the game begins.
  void startCountdown() {
    const oneSecond = Duration(seconds: 1);
    _countdownTimer = Timer.periodic(oneSecond, (timer) {
      setState(() {
        if (_countdown >= 1) {
          _countdown--;
        } else {
          // If the countdown is finished, cancel the timer and start the game
          _countdownTimer.cancel();
          _startGameTimer();
        }
      });
    });
  }

  /// Saves the user's score to Firebase Firestore.
  Future<void> _saveScore() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
    });
    if (loggedInUser.highestScore == null) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser?.uid)
          .set({'highest_score': 0}, SetOptions(merge: true));
    }
    if (score >= loggedInUser.highestScore!) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser?.uid)
          .set({'highest_score': score}, SetOptions(merge: true));
    }
  }

  /// Disposes of the timers when the widget is disposed to avoid memory leaks.
  @override
  void dispose() {
    _countdownTimer.cancel();
    _gameTimer.cancel();
    super.dispose();
  }
}
