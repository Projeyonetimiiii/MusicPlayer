import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onlinemusic/views/chat/models/chat_message.dart';
import 'package:flutter/material.dart';

import 'chat_input_field.dart';
import 'message.dart';

class Body extends StatelessWidget {
  final String rUid;
  final List<ChatMessage>? selectedMessage;
  final ValueChanged<ChatMessage>? longPressed;
  final ValueChanged<ChatMessage>? removeSelected;
  final ValueChanged<ChatMessage>? lastMessage;
  final ScrollController? controller;

  Body({
    required this.rUid,
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
    
      builder: (context, snap) {
        if (!snap.hasData) {
          return loading(rUid);
        }

        if (snap.data!.docs.isEmpty) {
          return empty(rUid, context);
        }

        List<ChatMessage> messages =
            snap.data!.docs.map((e) => ChatMessage.fromMap(e.data())).toList();

        return Column(
          children: [
            buildMessageList(messages, select),
            ChatInputField(
              rUid: rUid,
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
                print("Long pressed isSelect= " + isSelected.toString());
                if (!(message.isRemoved ?? true) && message.senderId == myUid) {
                  if (!isSelected)
                    longPressed!(message);
                  else
                    removeSelected!(message);
                }
              },
              onTap: () {
                if (!(message.isRemoved ?? true) && message.senderId == myUid) {
                  if (select) {
                    if (isSelected) {
                      removeSelected!(message);
                    } else {
                      longPressed!(message);
                    }
                  }
                }
              },
              child: Message(
                message: message,
                isSelected: isSelected,
                nextMessage: nextMessage,
                prevMessage: prevMessage,
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
            child: Container(
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white60, width: 1.6),
              ),
              child: Center(
                child: Text(
                  "HAYDİ HEMEN MESAJ YOLLA",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
        ChatInputField(
          rUid: uid,
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
          rUid: uid,
        ),
      ],
    );
  }
}
