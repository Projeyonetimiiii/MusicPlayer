import 'dart:convert';

class UserModel {
  String? image;
  String? email;
  String? userName;
  String? id;
  String? bio;
  UserModel({
    this.image,
    this.email,
    this.userName,
    this.id,
    this.bio
  });

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'email': email,
      'userName': userName,
      'id': id,
      'bio':bio
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      image: map['image'] != null ? map['image'] : null,
      email: map['email'] != null ? map['email'] : null,
      userName: map['userName'] != null ? map['userName'] : null,
      id: map['id'] != null ? map['id'] : null,
      bio: map['bio'] != null ? map['bio'] : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));
}
