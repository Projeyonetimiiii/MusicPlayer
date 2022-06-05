// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:onlinemusic/models/media_reference.dart';
import 'package:onlinemusic/util/enums.dart';

import '../../../enums/enums.dart';

class ChatMessage {
  final String? message;
  final String? senderId;
  final String? receiverId;
  final ChatMessageType? messageType;
  final MessageStatus? messageStatus;
  final int? messageTime;
  final bool? isRemoved;
  final List<MediaReference?>? images;
  final MediaReference? audio;
  ChatMessage({
    this.message,
    this.senderId,
    this.receiverId,
    this.messageType,
    this.messageStatus,
    this.messageTime,
    this.isRemoved,
    this.images,
    this.audio,
  });

  ChatMessage copyWith({
    String? message,
    String? senderId,
    String? receiverId,
    ChatMessageType? messageType,
    MessageStatus? messageStatus,
    int? messageTime,
    bool? isRemoved,
    List<MediaReference?>? images,
    MediaReference? audio,
  }) {
    return ChatMessage(
      message: message ?? this.message,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      messageType: messageType ?? this.messageType,
      messageStatus: messageStatus ?? this.messageStatus,
      messageTime: messageTime ?? this.messageTime,
      isRemoved: isRemoved ?? this.isRemoved,
      images: images ?? this.images,
      audio: audio ?? this.audio,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'message': message,
      'senderId': senderId,
      'receiverId': receiverId,
      'messageType': messageType?.index,
      'messageStatus': messageStatus?.index,
      'messageTime': messageTime,
      'isRemoved': isRemoved,
      'images': images?.map((x) => x?.toMap()).toList(),
      'audio': audio?.toMap(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      message: map['message'] != null ? map['message'] as String : null,
      senderId: map['senderId'] != null ? map['senderId'] as String : null,
      receiverId:
          map['receiverId'] != null ? map['receiverId'] as String : null,
      messageType: map['messageType'] != null
          ? ChatMessageType.values[map['messageType']]
          : null,
      messageStatus: map['messageStatus'] != null
          ? MessageStatus.values[map['messageStatus']]
          : null,
      messageTime:
          map['messageTime'] != null ? map['messageTime'] as int : null,
      isRemoved: map['isRemoved'] != null ? map['isRemoved'] as bool : null,
      images: map['images'] != null
          ? List<MediaReference?>.from(
              (map['images'] as List<int>).map<MediaReference?>(
                (x) => MediaReference?.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
      audio: map['audio'] != null
          ? MediaReference.fromMap(map['audio'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatMessage.fromJson(String source) =>
      ChatMessage.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ChatMessage(message: $message, senderId: $senderId, receiverId: $receiverId, messageType: $messageType, messageStatus: $messageStatus, messageTime: $messageTime, isRemoved: $isRemoved, images: $images, audio: $audio)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatMessage &&
        other.message == message &&
        other.senderId == senderId &&
        other.receiverId == receiverId &&
        other.messageType == messageType &&
        other.messageStatus == messageStatus &&
        other.messageTime == messageTime &&
        other.isRemoved == isRemoved &&
        listEquals(other.images, images) &&
        other.audio == audio;
  }

  @override
  int get hashCode {
    return message.hashCode ^
        senderId.hashCode ^
        receiverId.hashCode ^
        messageType.hashCode ^
        messageStatus.hashCode ^
        messageTime.hashCode ^
        isRemoved.hashCode ^
        images.hashCode ^
        audio.hashCode;
  }
}
