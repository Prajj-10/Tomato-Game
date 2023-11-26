/// Represents a user model with various attributes.
class UserModel {
  /// The unique identifier for the user.
  String? uid;

  /// The name of the user.
  String? name;

  /// The email address of the user.
  String? email;

  /// The password of the user.
  String? password;

  /// The highest score of the user in a general game context.
  int? highestScore;

  /// The highest score of the user in a classic game context.
  int? highestScoreClassic;

  /// Constructor for creating a [UserModel] instance.
  UserModel({
    this.uid,
    this.name,
    this.email,
    this.password,
    this.highestScore,
    this.highestScoreClassic,
  });

  /// Factory constructor for creating a [UserModel] instance from a map.
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      highestScore: map['highest_score'],
      highestScoreClassic: map['highest_score_classic'],
    );
  }

  /// Converts the [UserModel] object to a map for sending data to the server.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'password': password,
      'highest_score': highestScore,
      'highest_score_classic': highestScoreClassic,
    };
  }
}
