import 'package:firebase_auth/firebase_auth.dart';
import 'package:onlinemusic/util/enums.dart';
import 'package:onlinemusic/views/chat/messages/components/audio_message.dart';
import 'package:onlinemusic/views/chat/messages/components/image_message.dart';
import 'package:onlinemusic/views/chat/models/chat_message.dart';
import 'package:flutter/material.dart';
import 'text_message.dart';

class Message extends StatelessWidget {
  const Message({
    Key? key,
    this.isSelected = false,
    this.prevMessage,
    this.nextMessage,
    required this.message,
  }) : super(key: key);

  final ChatMessage message;
  final bool isSelected;
  final ChatMessage? prevMessage;
  final ChatMessage? nextMessage;
  Widget messageContaint(ChatMessage message) {
    switch (message.messageType) {
      case ChatMessageType.Text:
        return TextMessage(
          message: message,
          nextMessage: nextMessage,
          prevMessage: prevMessage,
        );
      case ChatMessageType.Audio:
        return AudioMessage(
          message: message,
          key: PageStorageKey(
            message.audio!.ref,
          ),
        );

      default:
        return ImageMessage(
          message: message,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMee = message.senderId == FirebaseAuth.instance.currentUser!.uid;
    return Container(
      color: isSelected
          ? Colors.grey.shade200.withOpacity(0.2)
          : Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMee ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isMee) ...[
            Text(getTime(message.messageTime!)),
            SizedBox(
              width: 5,
            )
          ],
          messageContaint(message),
          if (!isMee) ...[
            SizedBox(
              width: 5,
            ),
            Text(getTime(message.messageTime!)),
          ],
        ],
      ),
    );
  }

  String getTime(int millis) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(millis);
    return time.hour.toString() + ":" + time.minute.toString();
  }
}
