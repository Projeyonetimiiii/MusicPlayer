import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/models/blocked_details.dart';
import 'package:onlinemusic/models/usermodel.dart';
import 'package:onlinemusic/services/auth.dart';
import 'package:onlinemusic/services/messages_service.dart';
import 'package:onlinemusic/services/user_status_service.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/chat/models/chat_message.dart';
import 'package:onlinemusic/views/profile_screen.dart';

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
          title: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: AuthService().getUserStreamFromId(widget.user.id!),
              builder: (context, snapshot) {
                bool isOnline = widget.user.isOnline!;
                if (snapshot.hasData) {
                  UserModel user = UserModel.fromMap(snapshot.data!.data()!);
                  isOnline = user.isOnline!;
                }
                return Row(
                  children: [
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white,
                              image: DecorationImage(
                                image: NetworkImage(widget.user.image!),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -5,
                            right: -5,
                            child: CircleAvatar(
                              radius: 5,
                              backgroundColor:
                                  isOnline ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: () {
                        context.push(ProfileScreen(userModel: widget.user));
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: isOnline
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            widget.user.userName ?? "User",
                          ),
                          if (!isOnline)
                            Text(
                              Const.getDateTimeString(widget.user.lastSeen!),
                              style: TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
          actions: [
            if (selectedMessage.isNotEmpty) ...[
              IconButton(
                icon: Icon(Icons.delete_outline),
                onPressed: () async {
                  if (lastMessage != null) {
                    if (selectedMessage.any(
                        (e) => e.messageTime == lastMessage!.messageTime)) {
                      String docId = messagesService.getDoc(
                          FirebaseAuth.instance.currentUser!.uid,
                          widget.user.id!);
                      messagesService.updateChat(
                          docId,
                          lastMessage!.copyWith(
                            message: "mesaj silindi",
                          ));
                    }
                  }
                  selectedMessage.forEach((element) async {
                    await messagesService.deleteMessage(
                        widget.user.id!, element, context);
                    selectedMessage.remove(element);
                  });

                  selectedMessage.clear();
                  setState(() {});
                },
              ),
            ],
            StreamBuilder<List<BlockedDetails>>(
                stream: UserStatusService().blockedUsers,
                initialData: UserStatusService().blockedUsers.value,
                builder: (context, snapshot) {
                  List<BlockedDetails> blockedDetails = snapshot.data!;

                  bool isBlocked = blockedDetails
                      .any((e) => e.blockedUid == widget.user.id!);

                  return PopupMenuButton<int>(
                    onSelected: (v) {
                      UserStatusService service = UserStatusService();
                      if (v == 0) {
                        service.addNewBlockedUser(widget.user.id!);
                      } else {
                        service.deleteBlockedUser(widget.user.id!);
                      }
                    },
                    itemBuilder: (c) {
                      return [
                        if (!isBlocked)
                          PopupMenuItem(
                            value: 0,
                            child: Text("Engelle"),
                          ),
                        if (isBlocked)
                          PopupMenuItem(
                            value: 1,
                            child: Text("Engeli Kaldır"),
                          ),
                      ];
                    },
                  );
                }),
          ],
        ),
        body: Body(
          controller: _controller,
          lastMessage: (ChatMessage lastMessage) {
            this.lastMessage = lastMessage;
            //   if(mounted) setState(() {});
          },
          rUser: widget.user,
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
