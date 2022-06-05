import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:onlinemusic/views/chat/models/chat_message.dart';

class Chat {
  final ChatMessage message;
  final List<String> userIds;
  Chat({
    required this.message,
    required this.userIds,
  });

  Chat copyWith({
    ChatMessage? message,
    List<String>? userIds,
  }) {
    return Chat(
      message: message ?? this.message,
      userIds: userIds ?? this.userIds,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'message': message.toMap(),
      'userIds': userIds,
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      message: ChatMessage.fromMap(map['message'] as Map<String, dynamic>),
      userIds:
          (map['userIds'] as List<dynamic>).map((e) => e.toString()).toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Chat.fromJson(String source) =>
      Chat.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Chat(message: $message, userIds: $userIds)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Chat &&
        other.message == message &&
        listEquals(other.userIds, userIds);
  }

  @override
  int get hashCode => message.hashCode ^ userIds.hashCode;
}
