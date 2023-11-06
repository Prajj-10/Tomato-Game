import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:provider/provider.dart';
import 'package:tomato_game/google_authentication/google_sign_in.dart';

import '../Custom_Widgets/custom_button.dart';
import 'navigation.dart';
import 'signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late bool passwordVisible;
  // late bool _isLoading = true;

  // Firebase
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    passwordVisible = false;
  }

  emailField() {
    return TextFormField(
        autofocus: false,
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Please Enter Your Email");
          }
          // reg expression for email validation
          if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
              .hasMatch(value)) {
            return ("Please Enter a valid email");
          }
          return null;
        },
        onSaved: (value) {
          emailController.text = value!;
        },
        textInputAction: TextInputAction.next,
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

  //password field
  passwordField() {
    return TextFormField(
        autofocus: false,
        controller: passwordController,
        obscureText: !passwordVisible,
        validator: (value) {
          RegExp regex = RegExp(r'^.{6,}$');
          if (value!.isEmpty) {
            return ("Password is required for login");
          }
          if (!regex.hasMatch(value)) {
            return ("Password must be minimum 6 characters.");
          }
          return null;
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
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
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
                  FloatingActionButton.extended(
                    label: const Text(
                      'Sign Up with Google',
                      style: TextStyle(
                          fontFamily: 'Electronic Highway Sign',
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ), // <-- Text
                    backgroundColor: Colors.redAccent,
                    icon: const Icon(
                      FontAwesomeIcons.google,
                      size: 24,
                    ),
                    onPressed: () {
                      final provider = Provider.of<GoogleSignInProvider>(
                          context,
                          listen: false);
                      provider.googleLogin().whenComplete(() {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Navigation()));
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
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                                fontFamily: 'Electronic Highway Sign',
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        )
                      ])
                  /*CustomButton(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> const EmailPasswordSignup()));
                  },
                  text: 'Sign Up',
                ),*/
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void signIn(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((uid) => {
                AnimatedSnackBar.material(
                  "Login Successful",
                  type: AnimatedSnackBarType.success,
                  duration: const Duration(milliseconds: 1700),
                  mobilePositionSettings: const MobilePositionSettings(
                    topOnAppearance: 100,
                    topOnDissapear: 50,
                    // bottomOnAppearance: 100,
                    // bottomOnDissapear: 50,
                    // left: 20,
                    // right: 70,
                  ),
                ).show(context),
                //Fluttertoast.showToast(msg:"Login Successful"),
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const Navigation()))
              })
          .catchError((e) {
        AnimatedSnackBar.material(e!.message,
                type: AnimatedSnackBarType.error,
                mobileSnackBarPosition: MobileSnackBarPosition.top)
            .show(context);
        // Fluttertoast.showToast(msg: e!.message);
      });
    }
  }
}

// login function
