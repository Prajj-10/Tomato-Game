class UserModel {
  String? uid;
  String? name;
  String? email;
  String? password;
  int? highestScore;
  int? highestScoreClassic;

  UserModel(
      {this.uid,
      this.name,
      this.email,
      this.password,
      this.highestScore,
      this.highestScoreClassic});

  // receiving data from the server

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

  // sending data to server

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
