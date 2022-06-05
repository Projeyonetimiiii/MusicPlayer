// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:onlinemusic/util/enums.dart';

class UserModel {
  String? image;
  String? email;
  String? userName;
  String? id;
  String? bio;
  String? connectedUserId;
  ConnectionType? connectionType;
  UserModel({
    this.image,
    this.email,
    this.userName,
    this.id,
    this.bio,
    this.connectedUserId,
    this.connectionType,
  });

  UserModel copyWith({
    String? image,
    String? email,
    String? userName,
    String? id,
    String? bio,
    String? connectedUserId,
    ConnectionType? connectionType,
  }) {
    return UserModel(
      image: image ?? this.image,
      email: email ?? this.email,
      userName: userName ?? this.userName,
      id: id ?? this.id,
      bio: bio ?? this.bio,
      connectedUserId: connectedUserId ?? this.connectedUserId,
      connectionType: connectionType ?? this.connectionType,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'image': image,
      'email': email,
      'userName': userName,
      'id': id,
      'bio': bio,
      'connectedUserId': connectedUserId,
      'connectionType': connectionType?.index,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      image: map['image'] != null ? map['image'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      userName: map['userName'] != null ? map['userName'] as String : null,
      id: map['id'] != null ? map['id'] as String : null,
      bio: map['bio'] != null ? map['bio'] as String : null,
      connectedUserId: map['connectedUserId'] != null
          ? map['connectedUserId'] as String
          : null,
      connectionType: map['connectionType'] != null
          ? ConnectionType.values[map['connectionType'] as int]
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(image: $image, email: $email, userName: $userName, id: $id, bio: $bio, connectedUserId: $connectedUserId, connectionType: $connectionType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.image == image &&
        other.email == email &&
        other.userName == userName &&
        other.id == id &&
        other.bio == bio &&
        other.connectedUserId == connectedUserId &&
        other.connectionType == connectionType;
  }

  @override
  int get hashCode {
    return image.hashCode ^
        email.hashCode ^
        userName.hashCode ^
        id.hashCode ^
        bio.hashCode ^
        connectedUserId.hashCode ^
        connectionType.hashCode;
  }
}
