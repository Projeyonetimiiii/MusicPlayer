import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/views/chat/models/chat_message.dart';

class TextMessage extends StatelessWidget {
  const TextMessage(
      {Key? key, required this.message, this.nextMessage, this.prevMessage})
      : super(key: key);

  final ChatMessage message;
  final ChatMessage? prevMessage;
  final ChatMessage? nextMessage;

  @override
  Widget build(BuildContext context) {
    bool isMee = message.senderId == FirebaseAuth.instance.currentUser!.uid;
    return Material(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.65,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isMee ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          (message.message ?? ""),
          style: TextStyle(
            color: isMee ? Colors.white : Colors.black,
            fontStyle: (message.isRemoved ?? false)
                ? FontStyle.italic
                : FontStyle.normal,
          ),
        ),
      ),
    );
  }
}
