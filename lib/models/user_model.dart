class UserModel{
  String? uid;
  String? name;
  String? email;
  String? password;

  UserModel({this.uid, this.name, this.email, this.password});

  // receiving data from the server

  factory UserModel.fromMap(map){
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
    );
  }

  // sending data to server

  Map<String, dynamic> toMap(){
    return{
      'uid':uid,
      'name':name,
      'email':email,
      'password':password,
    };
  }
}