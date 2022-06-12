// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ConnectedSongModel {
  bool isAdmin;
  String userId;
  ConnectedSongModel({
    required this.isAdmin,
    required this.userId,
  });

  ConnectedSongModel copyWith({
    bool? isIAdmin,
    String? userId,
  }) {
    return ConnectedSongModel(
      isAdmin: isIAdmin ?? this.isAdmin,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isIAdmin': isAdmin,
      'userId': userId,
    };
  }

  factory ConnectedSongModel.fromMap(Map<String, dynamic> map) {
    return ConnectedSongModel(
      isAdmin: map['isIAdmin'] as bool,
      userId: map['userId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ConnectedSongModel.fromJson(String source) =>
      ConnectedSongModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ConnectedSongModel(isIAdmin: $isAdmin, userId: $userId)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConnectedSongModel &&
        other.isAdmin == isAdmin &&
        other.userId == userId;
  }

  @override
  int get hashCode => isAdmin.hashCode ^ userId.hashCode;
}
