import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:tomato_game/Custom_Widgets/custom_button.dart';
import 'package:tomato_game/Custom_Widgets/custom_textfield.dart';

import 'models/api_model.dart';
import 'models/user_model.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  late Future<QuestionAnswer?>? _futurequestion;
  final TextEditingController ansController = TextEditingController();

  // bool _isLoading = true;
  // // List<QuestionAnswer> questionAnswer = [];

  @override
  void initState(){
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value){
      loggedInUser = UserModel.fromMap(value.data());
      setState((){});
    });
    initfuture();
  }
  initfuture(){
    _futurequestion = getData();
  }
  QuestionAnswer? questionAns;
 Future<QuestionAnswer?> getData() async{
    try{
      String url = "https://marcconrad.com/uob/tomato/api.php";
      http.Response res = await http.get(Uri.parse(url));
      questionAns = QuestionAnswer.fromJson(json.decode(res.body));

      return questionAns;
    }
    catch(e){
      return null;
    //  debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Tomato Game"),
      ),
      body: //future builder
      FutureBuilder<QuestionAnswer?>(
          future:_futurequestion,
          builder: (BuildContext context, AsyncSnapshot<QuestionAnswer?> snapshot){
            switch (snapshot.connectionState){
              case ConnectionState.none:
                return Container(); // error//
              case ConnectionState.waiting: //loading
                return Center(child: Container(height: 20,width: 20,child: const Center(child: CircularProgressIndicator()),));
              case ConnectionState.done:
                if(snapshot.data==null){
                  return Container(child: Text("No data"),);// no data
                }else{
                  //ui
                  return Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 10,),
                          Text("Welcome ${loggedInUser.name!}"),
                          const SizedBox(height: 30,),
                          const Text("Enter the correct number: "),
                          const SizedBox(height: 20,),
                          Center(
                                child: Image.network(
                                  questionAns!.question,
                                  width: 400,
                                  height: 500,
                                ),
                              ),
                          const SizedBox(height: 20,),
                          Center(
                              child: TextField(
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: "Enter a value"
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value){
                                  int? enteredValue = int.tryParse(value);
                                  if(enteredValue != null){
                                    ansController.text = enteredValue.toString();
                                  }
                                },
                                style: const TextStyle(fontSize: 15),
                              )
                          ),
                          const SizedBox(height: 25,),
                          Center(
                            child: CustomButton(
                              onTap: () {
                                checkAnswer();
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
                return Container();//error page
            }
          }),

    );
  }
  void checkAnswer(){
    int value = int.tryParse(ansController.text) ?? 0; // Default sets to 0.
    if(value == questionAns!.solution){
      AnimatedSnackBar.material("Correct Answer",
          type: AnimatedSnackBarType.success,
          mobileSnackBarPosition: MobileSnackBarPosition.top).show(context);
      //getData();
      //Fluttertoast.showToast(msg: "Correct Answer");
    }
    else{
      AnimatedSnackBar.material("Wrong Answer",
          type: AnimatedSnackBarType.error,
          mobileSnackBarPosition: MobileSnackBarPosition.top).show(context);
      // Fluttertoast.showToast(msg: "Wrong Answer");
    }
  }



  /*@override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getData(),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          return ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index){
                return Container(
                  height: 150,
                  color: Colors.greenAccent,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal:10, ),
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:[
                      Text('Question : ${questionAnswer[index].question.toString()}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text('Answer : ${questionAnswer[index].solution.toString()}',
                          style:const TextStyle(fontSize: 18) )
                    ],
                  ),
                );
              }
          );
        }
        else if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator(),);
        }
        else{
          return const Text('No Data Available.');
        }
      }
    );
  }*/
  
  /*Future<List<QuestionAnswer>> getData() async {
    final response = await http.get(
        Uri.parse('http://marcconrad.com/uob/tomato/api.php'));
    var data = jsonDecode(response.body.toString());

    if (response.statusCode == 200) {
      for (Map<String, dynamic> index in data) {
        questionAnswer.add(QuestionAnswer.fromJson(index));
      }
      return questionAnswer;
      // questionAnswer = data.map((e)=> QuestionAnswer.fromJson(e)).toList();
    }
    else {
      return questionAnswer;
    }
  }*/

}
