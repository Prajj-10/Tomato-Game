import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:provider/provider.dart';
import 'package:tomato_game/google_authentication/google_sign_in.dart';
import 'package:tomato_game/pages/home_page.dart';

import '../Custom_Widgets/custom_button.dart';
import 'signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {



  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController =  TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late bool passwordVisible;


  // Firebase
  final _auth = FirebaseAuth.instance;

  @override
  void initState(){
    passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {

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
            return ("Password must be minimum 6 characters.");
          }
        },
        onSaved: (value) {
          passwordController.text = value!;
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.vpn_key),
          suffixIcon: IconButton(onPressed: (){
            setState(() {
              passwordVisible = !passwordVisible;
            });
          },icon: Icon(passwordVisible?Icons.visibility:Icons.visibility_off),),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    return Scaffold(
      body: SafeArea(
        child:SingleChildScrollView(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(36.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 25,),
                const Text("Tomato Game",
                style: TextStyle(fontSize: 30,
                    color: Colors.redAccent,
                fontWeight: FontWeight.bold),),
                const SizedBox(height: 25,),
                SizedBox(
                  height: 200,
                  child: Image.asset("assets/tomato-spin.gif",
                    fit: BoxFit.contain,),  // Image location
                ),
                const SizedBox( height: 45,),
                emailField,
                const SizedBox(height: 25,),
                passwordField,
                const SizedBox(height: 25,),
                CustomButton(
                  onTap: () {
                    signIn(emailController.text, passwordController.text);
                  },
                  text: 'Login',
                ),
                const SizedBox(height: 25,),
                FloatingActionButton.extended(
                  label: const Text('Sign Up with Google',
                    style: TextStyle(color: Colors.black,
                        fontSize: 18, fontWeight: FontWeight.bold),), // <-- Text
                  backgroundColor: Colors.redAccent,
                  icon:  const Icon(FontAwesomeIcons.google,
                    size: 24,),
                  onPressed: () {
                    final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
                    provider.googleLogin();
                    if(provider.googleLogin() == true){
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>  const HomePage()));
                    }
                     }, // <-- Icon,
                ),
                const SizedBox(height: 20,),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("Don't have an account? ",
                        style: TextStyle(fontSize: 15,
                            fontWeight: FontWeight.bold) ,),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const EmailPasswordSignup()));
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
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

  /*signInWithGoogle() async{

    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken
    );

    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    print(userCredential.user?.displayName);

  }*/

  void signIn(String email, String password) async{
    if(_formKey.currentState!.validate()){
      await _auth.signInWithEmailAndPassword(email: email, password: password)
          .then((uid) => {
            AnimatedSnackBar.material("Login Successful",
            type: AnimatedSnackBarType.success,
            mobileSnackBarPosition: MobileSnackBarPosition.top).show(context),
            //Fluttertoast.showToast(msg:"Login Successful"),
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> const HomePage()))
      }).catchError((e){
        AnimatedSnackBar.material(e!.message,
            type: AnimatedSnackBarType.error,
            mobileSnackBarPosition: MobileSnackBarPosition.top).show(context);
        // Fluttertoast.showToast(msg: e!.message);
      });

    }
  }
}

// login function
