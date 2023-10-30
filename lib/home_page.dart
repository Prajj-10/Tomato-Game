import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:tomato_game/Custom_Widgets/custom_button.dart';
import 'package:tomato_game/Custom_Widgets/custom_textfield.dart';

import 'models/api_model.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final TextEditingController ansController = TextEditingController();

  bool _isLoading = true;
  // List<QuestionAnswer> questionAnswer = [];

  @override
  void initState(){
    super.initState();
    getData();
  }

  QuestionAnswer? questionAns;
  getData() async{
    try{
      String url = "https://marcconrad.com/uob/tomato/api.php";
      http.Response res = await http.get(Uri.parse(url));
      questionAns = QuestionAnswer.fromJson(json.decode(res.body));
      _isLoading = false;
      setState(() {});
    }
    catch(e){
      debugPrint(e.toString());
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
      body: Padding(
        padding: const EdgeInsets.all(36.0),
        child: SingleChildScrollView(
            child: Column(
              children: [
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
      ),
    );
  }
  void checkAnswer(){
    int value = int.tryParse(ansController.text) ?? 0; // Default sets to 0.
    if(value == questionAns!.solution){
      AnimatedSnackBar.material("Correct Answer",
          type: AnimatedSnackBarType.success,
          mobileSnackBarPosition: MobileSnackBarPosition.top).show(context);
      getData();
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
