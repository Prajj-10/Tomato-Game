import 'dart:convert';

/// Converts a JSON [String] to a [QuestionAnswer] object.
QuestionAnswer questionAnswerFromJson(String str) =>
    QuestionAnswer.fromJson(json.decode(str));

/// Converts a [QuestionAnswer] object to a JSON [String].
String questionAnswerToJson(QuestionAnswer data) => json.encode(data.toJson());

/// Represents a question and its corresponding solution.
class QuestionAnswer {
  /// The question text.
  String question;

  /// The solution to the question.
  int solution;

  /// Constructor for creating a [QuestionAnswer] instance.
  ///
  /// Both [question] and [solution] are required.
  QuestionAnswer({
    required this.question,
    required this.solution,
  });

  /// Factory constructor for creating a [QuestionAnswer] instance from a JSON map.
  factory QuestionAnswer.fromJson(Map<String, dynamic> json) => QuestionAnswer(
        question: json["question"],
        solution: json["solution"],
      );

  /// Converts the [QuestionAnswer] object to a JSON map.
  Map<String, dynamic> toJson() => {
        "question": question,
        "solution": solution,
      };
}
