import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onlinemusic/models/usermodel.dart';
import 'package:onlinemusic/services/messages_service.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/views/chat/models/chat_message.dart';
import 'package:flutter/material.dart';

import 'chat_input_field.dart';
import 'message.dart';

class Body extends StatelessWidget {
  final UserModel rUser;
  final List<ChatMessage>? selectedMessage;
  final ValueChanged<ChatMessage>? longPressed;
  final ValueChanged<ChatMessage>? removeSelected;
  final ValueChanged<ChatMessage>? lastMessage;
  final ScrollController? controller;

  Body({
    required this.rUser,
    this.longPressed,
    this.selectedMessage,
    this.removeSelected,
    this.lastMessage,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    bool select = selectedMessage!.isNotEmpty;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: messagesService.getSortedMessageStream(
          FirebaseAuth.instance.currentUser!.uid, rUser.id!),
      builder: (context, snap) {
        if (!snap.hasData) {
          return loading(rUser.id!);
        }

        if (snap.data!.docs.isEmpty) {
          return empty(rUser.id!, context);
        }

        List<ChatMessage> messages =
            snap.data!.docs.map((e) => ChatMessage.fromMap(e.data())).toList();

        return Column(
          children: [
            buildMessageList(messages, select),
            ChatInputField(
              rUser: rUser,
            ),
          ],
        );
      },
    );
  }

  Expanded buildMessageList(
    List<ChatMessage> messages,
    bool select,
  ) {
    lastMessage!(messages.first);
    String myUid = FirebaseAuth.instance.currentUser!.uid;
    return Expanded(
      child: ListView.builder(
          reverse: true,
          physics: BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 3),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            bool isSelected = selectedMessage!
                .any((e) => e.messageTime == messages[index].messageTime);
            ChatMessage? nextMessage;
            ChatMessage? prevMessage;
            ChatMessage message = messages[index];
            if (index < messages.length - 2) {
              nextMessage = messages[index + 1];
            }
            if (index >= 1) {
              prevMessage = messages[index - 1];
            }

            return GestureDetector(
              onLongPress: () {
                if (!(message.isRemoved ?? false) &&
                    message.senderId == myUid) {
                  if (!isSelected)
                    longPressed!(message);
                  else
                    removeSelected!(message);
                }
              },
              onTap: () {
                if (!(message.isRemoved ?? false) &&
                    message.senderId == myUid) {
                  if (select) {
                    if (isSelected) {
                      removeSelected!(message);
                    } else {
                      longPressed!(message);
                    }
                  }
                }
              },
              child: Container(
                color:
                    isSelected ? Const.contrainsColor.withOpacity(0.2) : null,
                child: Message(
                  message: message,
                  isSelected: isSelected,
                  nextMessage: nextMessage,
                  prevMessage: prevMessage,
                ),
              ),
            );
          }),
    );
  }

  Widget empty(String uid, BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Text(
              "HAYDİ HEMEN MESAJ YOLLA",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        ChatInputField(
          rUser: rUser,
        ),
      ],
    );
  }

  Widget loading(String uid) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Text("Yükleniyor"),
          ),
        ),
        ChatInputField(
          rUser: rUser,
        ),
      ],
    );
  }
}
