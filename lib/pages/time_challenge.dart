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
import 'package:tomato_game/pages/play_game.dart';
import '../google_authentication/google_sign_in.dart';
import '../models/api_model.dart';
import '../models/user_model.dart';
import 'navigation.dart';

class TimeChallengeGame extends StatefulWidget {
  const TimeChallengeGame({super.key});

  @override
  State<TimeChallengeGame> createState() => _TimeChallengeGameState();
}

class _TimeChallengeGameState extends State<TimeChallengeGame> {
  int score = 0; // Initialize the score
  late Timer _gameTimer;
  int _timeLeft = 120; // Set the initial time in seconds

  late Timer _countdownTimer;
  int _countdown = 3;

  late Timer _dialogTimer;
  int _dialogCountdown = 3;

  final _formKey = GlobalKey<FormState>();

  // User Model to map data of the User.
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  // Google Sign In object.
  final googleSignIn = GoogleSignIn();

  // late varible which gets initialized later
  late Future<QuestionAnswer?>? _futurequestion;

  // Answer controller to receive answer
  TextEditingController ansController = TextEditingController();

  List<QuestionAnswer> questionAnswer = [];

  @override
  void initState() {
    // Initializes Firebase and gets data in loggedinUser from user.
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      //startCountdown();
      //_showGameDialog();
    });

    initfuture();
    _startGameTimer();
  }

  initfuture() {
    // As asyncs can't be called in init, this is a workaround.
    _futurequestion = getData();
  }

  @override
  Widget build(BuildContext context) {
    // Phone Size
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
              // Gradient of the page.
              const Color(0xF29F9F).withOpacity(0.9),
              const Color(0xFAFAFA).withOpacity(1.0),
            ],
            // Gradient Pattern
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )),
          child: FutureBuilder<QuestionAnswer?>(
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
                                          fontFamily:
                                              'Electronic Highway Sign'),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 63,
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
                                  checkAnswer(); // Function to check ans being called
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
      ),
    );
  }

  // The main function that is being called to get data from API.
  QuestionAnswer? questionAns;

  Future<QuestionAnswer?> getData() async {
    try {
      String url = "https://marcconrad.com/uob/tomato/api.php";
      http.Response res = await http.get(Uri.parse(url));
      questionAns = QuestionAnswer.fromJson(json.decode(res.body));
      return questionAns;
    } catch (e) {
      return null;
    }
  }

  // Starts the game timer and shows the Game over dialog when the time is over.
  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _gameTimer.cancel();
          _showGameOverDialog();
        }
      });
    });
  }

  // Logs the user out from their account.
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

  // Checks for answer if it's correct or not.
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
        score++;
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

  // Function to restart the game
  void _restartGame() {
    // Reset the game state, including score, timer, and other relevant data.
    setState(() {
      score = 0;
      _timeLeft = 120; // Reset the timer to the initial time
    });
    // Starts the game again.
    _startGameTimer();
  }

  // Function to navigate to the home screen
  void _navigateToHomeScreen() {
    // Navigator to navigate to the home screen or any other desired screen.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Navigation()),
    );
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

  // Shows the game over dialog.
  void _showGameOverDialog() {
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

  Future<void> _skipQuestion() async {
    QuestionAnswer? newQuestion = await getData();
    setState(() {
      questionAns = newQuestion;
      ansController.clear(); // Clear the input field
      _timeLeft -= 5;
    });
  }

  void startCountdown() {
    const oneSecond = Duration(seconds: 1);
    _countdownTimer = Timer.periodic(oneSecond, (timer) {
      setState(() {
        if (_countdown > 1) {
          _countdown--;
        } else {
          // If the countdown is finished, cancel the timer and start the game
          _countdownTimer.cancel();
          // TODO: Add code to start the game or load game content
          // After countdown, show the game screen or do whatever is needed
          Navigator.pop(context);
        }
      });
    });
  }

  void _showGameDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent users from closing the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game is starting in...'),
          content: Center(
            child: Text(
              '$_countdown',
              style: TextStyle(fontSize: 48),
            ),
          ),
          actions: <Widget>[
            // No action buttons in this case
          ],
        );
      },
    );
  }
}
