// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class RequestModel {
  String senderId;
  String receiverId;
  RequestType type;
  RequestModel({
    required this.senderId,
    required this.receiverId,
    required this.type,
  });

  RequestModel copyWith({
    String? senderId,
    String? receiverId,
    RequestType? type,
  }) {
    return RequestModel(
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'senderId': senderId,
      'receiverId': receiverId,
      'type': type.index,
    };
  }

  factory RequestModel.fromMap(Map<String, dynamic> map) {
    return RequestModel(
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      type: RequestType.values[map['type']],
    );
  }

  String toJson() => json.encode(toMap());

  factory RequestModel.fromJson(String source) =>
      RequestModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'RequestModel(senderId: $senderId, receiverId: $receiverId, type: $type)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RequestModel &&
        other.senderId == senderId &&
        other.receiverId == receiverId &&
        other.type == type;
  }

  @override
  int get hashCode => senderId.hashCode ^ receiverId.hashCode ^ type.hashCode;
}

enum RequestType { Waiting, Accepted, Denied }
