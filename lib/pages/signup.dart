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

class _EmailPasswordSignupState extends State<EmailPasswordSignup> {
  final _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();

  // Hide and Unhide password Button

  late bool passwordVisible;

  @override
  void initState() {
    passwordVisible = false;
  }

  /*void signUpUser() async {
    context.read<FirebaseAuthMethods>().signUpWithEmail(
      email: emailController.text,
      password: passwordController.text,
      context: context,
    );
  }*/

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    // Name Field

    final nameField = TextFormField(
        autofocus: false,
        controller: nameController,
        keyboardType: TextInputType.name,
        validator: (value) {
          RegExp regex = RegExp(r'^.{3,}$');
          if (value!.isEmpty) {
            return ("Name cannot be Empty");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter a Valid name(Min. 3 Character)");
          }
          return null;
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

    // Email Field

    final emailField = TextFormField(
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
              fontWeight: FontWeight.bold),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    //password field
    final passwordField = TextFormField(
        autofocus: false,
        controller: passwordController,
        obscureText: !passwordVisible,
        validator: (value) {
          RegExp regex = RegExp(r'^.{6,}$');
          if (value!.isEmpty) {
            return ("Password is required for login");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter Valid Password(Min. 6 Character)");
          }
          return null;
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

    //confirm password field
    final confirmPasswordField = TextFormField(
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xF29F9F).withOpacity(0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(36.0),
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /*Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.arrow_back)),
                  ),*/
                  /*const SizedBox(
                    height: 100,
                  ),*/
                  const Text(
                    "Sign Up",
                    style: TextStyle(
                        fontSize: 30,
                        fontFamily: 'Electronic Highway Sign',
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                  nameField,
                  /*Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: CustomTextField(
                      controller: nameController,
                      hintText: 'Enter your name',
                    ),
                  ),*/
                  const SizedBox(height: 20),
                  emailField,
                  /*Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: CustomTextField(
                      controller: emailController,
                      hintText: 'Enter your email',
                    ),
                  ),*/
                  const SizedBox(
                    height: 20,
                  ),
                  passwordField,
                  /*Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: CustomTextField(
                      controller: passwordController,
                      hintText: 'Enter your password',
                    ),
                  ),*/
                  const SizedBox(height: 20),
                  confirmPasswordField,
                  const SizedBox(height: 40),
                  CustomButton(
                    onTap: () {
                      signUp(emailController.text, passwordController.text);
                      //Navigator.pushNamed(context, EmailPasswordLogin.routeName);
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
    );
  }

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
            // topOnDissapear: 50,
            // bottomOnAppearance: 100,
            //bottomOnDissapear: 50,
            // left: 20,
            // right: 70,
          ),
        ).show(context);
        // Fluttertoast.showToast(msg: e!.message);
      });
    }
  }

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
    //Fluttertoast.showToast(msg: "Account created successfully.");

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false);
  }
}
