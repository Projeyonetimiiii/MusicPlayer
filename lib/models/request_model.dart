// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:onlinemusic/util/enums.dart';

class RequestModel {
  String senderId;
  String receiverId;
  ResultType resultType;
  RequestType requestType;
  RequestModel({
    required this.senderId,
    required this.receiverId,
    required this.resultType,
    required this.requestType,
  });

  RequestModel copyWith({
    String? senderId,
    String? receiverId,
    ResultType? resultType,
    RequestType? requestType,
  }) {
    return RequestModel(
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      resultType: resultType ?? this.resultType,
      requestType: requestType ?? this.requestType,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'senderId': senderId,
      'receiverId': receiverId,
      'resultType': resultType.index,
      'requestType': requestType.index,
    };
  }

  factory RequestModel.fromMap(Map<String, dynamic> map) {
    return RequestModel(
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      resultType: ResultType.values[map['resultType']],
      requestType: RequestType.values[map['requestType']],
    );
  }

  String toJson() => json.encode(toMap());

  factory RequestModel.fromJson(String source) =>
      RequestModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RequestModel(senderId: $senderId, receiverId: $receiverId, resultType: $resultType, requestType: $requestType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RequestModel &&
        other.senderId == senderId &&
        other.receiverId == receiverId &&
        other.resultType == resultType &&
        other.requestType == requestType;
  }

  @override
  int get hashCode {
    return senderId.hashCode ^
        receiverId.hashCode ^
        resultType.hashCode ^
        requestType.hashCode;
  }
}
