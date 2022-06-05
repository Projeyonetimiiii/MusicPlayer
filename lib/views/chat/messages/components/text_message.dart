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
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.65,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.green,
      ),
      child: Text(
        message.message ?? "",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontStyle:
              message.isRemoved ?? true ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }
}
