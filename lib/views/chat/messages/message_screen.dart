import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/models/usermodel.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/chat/models/chat_message.dart';
import 'package:onlinemusic/views/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'components/body.dart';

class MessagesScreen extends StatefulWidget {
  final UserModel user;

  MessagesScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<ChatMessage> selectedMessage = [];
  ChatMessage? lastMessage;
  ScrollController? _controller;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectedMessage.isNotEmpty) {
          selectedMessage.clear();
          setState(() {});
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: InkWell(
            onTap: () {
              context.push(ProfileScreen(userModel: widget.user));
            },
            child: Text(
              widget.user.userName ?? "User",
            ),
          ),
        ),
        body: Body(
          controller: _controller,
          lastMessage: (ChatMessage lastMessage) {
            this.lastMessage = lastMessage;
            //   if(mounted) setState(() {});
          },
          rUid: widget.user.id!,
          selectedMessage: selectedMessage,
          removeSelected: (ChatMessage snap) {
            print("remove = " + snap.toString());
            selectedMessage.removeWhere(
                (element) => element.messageTime == snap.messageTime);
            setState(() {});
          },
          longPressed: (ChatMessage snap) {
            selectedMessage.add(snap);
            setState(() {});
          },
        ),
      ),
    );
  }
}
