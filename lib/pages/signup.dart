import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Custom_Widgets/custom_button.dart';
import 'login_page.dart';
import '../models/user_model.dart';

class EmailPasswordSignup extends StatefulWidget {
  // static String routeName = '/signup.dart';   // The routes are created at main.dart to route the pages properly.
  const EmailPasswordSignup({Key? key}) : super(key: key);

  @override
  _EmailPasswordSignupState createState() => _EmailPasswordSignupState();
}

class _EmailPasswordSignupState extends State<EmailPasswordSignup>
    with InputValidationMixin {
  // Firebase Auth instance
  final _auth = FirebaseAuth.instance;

  // Form Key for Form to validators.
  final _formKey = GlobalKey<FormState>();

  // Text Controllers for TextFormField
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();

  // Hide and Unhide password Button

  late bool passwordVisible;

  String? errorMessage;

  @override
  void initState() {
    // Initially the password is hidden.
    passwordVisible = false;
  }

  // Name Field
  nameField() {
    return TextFormField(
        autofocus: false,
        controller: nameController,
        keyboardType: TextInputType.name,
        validator: (name) {
          if (isNameValid(name!)) {
            return null;
          } else {
            return 'Enter a valid name containing at least 6 characters.';
          }
        },
        onSaved: (value) {
          nameController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.account_circle),
          contentPadding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
          hintText: "Name",
          hintStyle: TextStyle(
              fontFamily: 'Electronic Highway Sign',
              fontWeight: FontWeight.bold),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));
  }

  // Email Field
  emailField() {
    return TextFormField(
        autofocus: false,
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        validator: (email) {
          if (isEmailValid(email!)) {
            return null;
          } else {
            return 'Enter a valid email address.';
          }
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
              fontWeight: FontWeight.bold),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));
  }

  // Password Field
  passwordField() {
    return TextFormField(
        autofocus: false,
        controller: passwordController,
        obscureText: !passwordVisible,
        validator: (password) {
          if (passwordStructure(password!)) {
            return null;
          } else {
            return 'Enter a valid password. \n'
                'Password must contain: \n'
                '1.) One upper case \n'
                '2.) One lower case \n'
                '3.) One numeric number \n'
                '4.) One special character \n'
                '5.) Minimum 8 characters \n';
          }
        },
        onSaved: (value) {
          passwordController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.vpn_key),
          suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  passwordVisible = !passwordVisible;
                });
              },
              icon: Icon(
                passwordVisible ? Icons.visibility : Icons.visibility_off,
              )),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Password",
          hintStyle: TextStyle(
              fontFamily: 'Electronic Highway Sign',
              fontWeight: FontWeight.bold),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));
  }

  // Confirm Password Field
  confirmPasswordField() {
    return TextFormField(
        autofocus: false,
        controller: confirmPwController,
        obscureText: !passwordVisible,
        validator: (value) {
          if (confirmPwController.text != passwordController.text) {
            return "Password don't match";
          }
          return null;
        },
        onSaved: (value) {
          confirmPwController.text = value!;
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.vpn_key),
          suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  passwordVisible = !passwordVisible;
                });
              },
              icon: Icon(
                passwordVisible ? Icons.visibility : Icons.visibility_off,
              )),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Confirm Password",
          hintStyle: TextStyle(
              fontFamily: 'Electronic Highway Sign',
              fontWeight: FontWeight.bold),
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
      appBar: AppBar(
          backgroundColor: Color(0xF29F9F).withOpacity(0.9),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_outlined),
            color: Colors.black,
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: SingleChildScrollView(
        child: Container(
          //height: size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [
              const Color(0xF29F9F).withOpacity(0.9),
              const Color(0xFAFAFA).withOpacity(1.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )),
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Form(
              key: _formKey,
              child: Center(
                child: Column(
                  // Shows the Text Fields in the center
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 70,
                    ),
                    const Text(
                      "Sign Up",
                      style: TextStyle(
                          fontSize: 30,
                          fontFamily: 'Electronic Highway Sign',
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                    nameField(),
                    const SizedBox(height: 20),
                    emailField(),
                    const SizedBox(
                      height: 20,
                    ),
                    passwordField(),
                    const SizedBox(height: 20),
                    confirmPasswordField(),
                    const SizedBox(height: 40),
                    CustomButton(
                      onTap: () {
                        signUp(emailController.text, passwordController.text);
                      },
                      text: 'Sign Up',
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Function to Sign up in Firebase.
  void signUp(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => {
                postDetailsToFireStore(),
              })
          .catchError((e) {
        AnimatedSnackBar.material(
          e!.message,
          type: AnimatedSnackBarType.error,
          duration: const Duration(milliseconds: 1700),
          mobilePositionSettings: const MobilePositionSettings(
            topOnAppearance: 100,
          ),
        ).show(context);
      });
    }
  }

  // Inserts the details entered in the Firebase Fire store.
  postDetailsToFireStore() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    User? user = _auth.currentUser;

    UserModel userModel = UserModel();
    userModel.uid = user!.uid;
    userModel.name = nameController.text;
    userModel.email = emailController.text;
    userModel.password = passwordController.text;

    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap());
    AnimatedSnackBar.material(
      "Account Created Successfully",
      type: AnimatedSnackBarType.success,
      duration: const Duration(milliseconds: 1700),
      mobilePositionSettings: const MobilePositionSettings(
        topOnAppearance: 100,
      ),
    ).show(context);

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false);
  }
}

mixin InputValidationMixin {
  bool isNameValid(String name) => name.length >= 6 && name.isNotEmpty;

  bool passwordStructure(String value) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  bool isEmailValid(String email) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }
}
