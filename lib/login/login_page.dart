import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:provider/provider.dart';
import 'package:tomato_game/custom_widgets/custom_loading.dart';
import 'package:tomato_game/google_authentication/google_sign_in.dart';
import '../../Custom_Widgets/custom_button.dart';
import '../../navigation_handler/navigation.dart';
import '../registration/signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with InputValidationMixin {
  // Form Key to collect data and for validation.
  final _formKey = GlobalKey<FormState>();

  // Text Editing Controllers for TextFormFields.
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // boolean variable for hide and un-hide password.
  late bool passwordVisible;

  // Firebase
  final _auth = FirebaseAuth.instance;
  String? errorMessage;

  @override
  void initState() {
    // Initially made invisible.
    passwordVisible = false;
  }

  // Email Field.
  emailField() {
    return TextFormField(
        autofocus: false,
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        validator: (email) {
          if (isEmailValid(email!)) {
            return null;
          } else {
            return 'Enter a valid email address';
          }
        },
        onSaved: (value) {
          emailController.text = value!;
        },
        textInputAction: TextInputAction.next,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.mail),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Email",
          hintStyle: TextStyle(
              fontFamily: 'Electronic Highway Sign',
              fontWeight: FontWeight.bold,
              color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));
  }

  //Password field
  passwordField() {
    return TextFormField(
        autofocus: false,
        controller: passwordController,
        obscureText: !passwordVisible,
        validator: (password) {
          if (isPasswordValid(password!)) {
            return null;
          } else {
            return 'Enter a valid password';
          }
        },
        onSaved: (value) {
          passwordController.text = value!;
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.vpn_key,
          ),
          iconColor: Colors.black,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                passwordVisible = !passwordVisible;
              });
            },
            icon:
                Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Password",
          hintStyle: TextStyle(
              fontFamily: 'Electronic Highway Sign',
              fontWeight: FontWeight.bold,
              color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    // Phone Size
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: size.height,
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [
                // Gradient Colour with opacity
                const Color(0xF29F9F).withOpacity(0.9),
                const Color(0xFAFAFA).withOpacity(1.0),
              ],
              // Pattern of the Gradient.
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )),
            padding: const EdgeInsets.all(36.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 70,
                  ),
                  const Text(
                    "Login",
                    style: TextStyle(
                        fontFamily: 'Electronic Highway Sign',
                        fontSize: 40,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  SizedBox(
                    height: 200,
                    child: Image.asset(
                      "assets/images/tomato-spin.gif",
                      fit: BoxFit.contain,
                    ), // Image location
                  ),
                  const SizedBox(
                    height: 45,
                  ),
                  emailField(),
                  const SizedBox(
                    height: 25,
                  ),
                  passwordField(),
                  const SizedBox(
                    height: 25,
                  ),
                  CustomButton(
                    onTap: () {
                      signIn(emailController.text, passwordController.text);
                    },
                    text: 'Login',
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  // Button for Signing up with Google.
                  FloatingActionButton.extended(
                    label: const Text(
                      'Sign Up with Google',
                      style: TextStyle(
                          fontFamily: 'Electronic Highway Sign',
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ), // <-- Text
                    backgroundColor: Color(0xF29F9F).withOpacity(1.0),
                    icon: const Icon(
                      FontAwesomeIcons.google,
                      size: 24,
                    ),
                    onPressed: () {
                      SmartDialog.showLoading(
                        msg: "Logging In...",
                        builder: (_) => CustomLoading(type: 2),
                        maskColor: Colors.transparent,
                        animationType: SmartAnimationType.scale,
                        //msg: "Loading",
                        backDismiss: false,
                      );
                      // Function to sign up the user with Google.
                      final provider = Provider.of<GoogleSignInProvider>(
                          context,
                          listen: false);
                      provider.googleLogin().whenComplete(() {
                        SmartDialog.dismiss();
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Navigation()),
                            (Route<dynamic> route) => false);
                      });
                    }, // <-- Icon,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Electronic Highway Sign'),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const EmailPasswordSignup()),
                            );
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                                fontFamily: 'Electronic Highway Sign',
                                color: Color(0xF29F9F).withOpacity(1.0),
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        )
                      ])
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Function to Sign in with Email and Password.
  void signIn(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      SmartDialog.showLoading(
        msg: "Logging In...",
        builder: (_) => CustomLoading(type: 2),
        maskColor: Color(0xF29F9F).withOpacity(1.0),
        animationType: SmartAnimationType.scale,
        //msg: "Loading",
        backDismiss: false,
      );
      try {
        await _auth
            .signInWithEmailAndPassword(email: email, password: password)
            .then((uid) => {
                  SmartDialog.dismiss(),
                  AnimatedSnackBar.material(
                    "Login Successful",
                    type: AnimatedSnackBarType.success,
                    duration: const Duration(milliseconds: 1700),
                    mobilePositionSettings: const MobilePositionSettings(
                      topOnAppearance: 100,
                      topOnDissapear: 50,
                    ),
                  ).show(context),
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const Navigation()),
                      (Route<dynamic> route) => false),
                });
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage = "Your email address appears to be malformed.";
            break;
          case "wrong-password":
            errorMessage = "Your password is wrong.";
            break;
          case "user-not-found":
            errorMessage = "User with this email doesn't exist.";
            break;
          case "user-disabled":
            errorMessage = "User with this email has been disabled.";
            break;
          case "too-many-requests":
            errorMessage = "Too many requests";
            break;
          case "operation-not-allowed":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "An undefined Error happened.";
        }
        AnimatedSnackBar.material(errorMessage!,
                type: AnimatedSnackBarType.error,
                mobileSnackBarPosition: MobileSnackBarPosition.top,
                desktopSnackBarPosition: DesktopSnackBarPosition.topRight)
            .show(context);
        // print(error.code);
      }
    }
  }
}

mixin InputValidationMixin {
  bool isPasswordValid(String password) => password.length >= 6;

  bool isEmailValid(String email) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }
}
