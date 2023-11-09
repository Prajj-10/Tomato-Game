import 'dart:convert';

QuestionAnswer questionAnswerFromJson(String str) =>
    QuestionAnswer.fromJson(json.decode(str));

String questionAnswerToJson(QuestionAnswer data) => json.encode(data.toJson());

class QuestionAnswer {
  String question;
  int solution;

  QuestionAnswer({
    required this.question,
    required this.solution,
  });

  factory QuestionAnswer.fromJson(Map<String, dynamic> json) => QuestionAnswer(
        question: json["question"],
        solution: json["solution"],
      );

  Map<String, dynamic> toJson() => {
        "question": question,
        "solution": solution,
      };
}
