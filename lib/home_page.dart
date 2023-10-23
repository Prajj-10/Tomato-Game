import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tomato_game/API_Model/model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      appBar: AppBar(
        title: const Text("Tomato Game"),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.network(
                  questionAns!.question,
                  width: 400,
                  height: 500,
                ),
                Text(questionAns!.solution.toString()),
              ],
            ),
          );
        }
      ),
    );
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
