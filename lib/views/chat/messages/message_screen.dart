import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/models/blocked_details.dart';
import 'package:onlinemusic/models/usermodel.dart';
import 'package:onlinemusic/services/auth.dart';
import 'package:onlinemusic/services/messages_service.dart';
import 'package:onlinemusic/services/user_status_service.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/enums.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/chat/models/chat_message.dart';
import 'package:onlinemusic/views/profile_screen/profile_screen.dart';
import 'package:onlinemusic/widgets/custom_back_button.dart';

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
          titleSpacing: 0,
          leading: CustomBackButton(),
          title: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: AuthService().getUserStreamFromId(widget.user.id!),
            builder: (context, snapshot) {
              bool isOnline = widget.user.isOnline!;
              if (snapshot.hasData) {
                UserModel user = UserModel.fromMap(snapshot.data!.data()!);
                isOnline = user.isOnline!;
              }
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 350),
                child: selectedMessage.isNotEmpty
                    ? Row(
                        key: ValueKey("selector"),
                        children: [
                          Text(selectedMessage.length.toString()),
                        ],
                      )
                    : Row(
                        key: ValueKey("title"),
                        children: [
                          Center(
                            child: SizedBox.square(
                              dimension: 45,
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                shape: StadiumBorder(),
                                child: Hero(
                                  tag: (widget.user.id.toString()) + "i",
                                  child: Material(
                                    elevation: 0,
                                    clipBehavior: Clip.antiAlias,
                                    shape: StadiumBorder(),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.user.image!,
                                      fit: BoxFit.cover,
                                      placeholder: (c, i) {
                                        return CircleAvatar(
                                          backgroundColor: Const.contrainsColor
                                              .withOpacity(0.1),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              context
                                  .push(ProfileScreen(userModel: widget.user));
                            },
                            child: getUserNameWidget(isOnline),
                          ),
                        ],
                      ),
              );
            },
          ),
          actions: [
            AnimatedSwitcher(
              duration: Duration(milliseconds: 350),
              child: selectedMessage.isEmpty
                  ? SizedBox()
                  : IconButton(
                      icon: Icon(Icons.delete_outline),
                      onPressed: () async {
                        if (lastMessage != null) {
                          if (selectedMessage.any((e) =>
                              e.messageTime == lastMessage!.messageTime)) {
                            String docId = messagesService.getDoc(
                                FirebaseAuth.instance.currentUser!.uid,
                                widget.user.id!);
                            messagesService.updateChat(
                              docId,
                              lastMessage!.copyWith(
                                message: "mesaj silindi",
                                audio: null,
                                images: null,
                                messageType: ChatMessageType.Text,
                              ),
                            );
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
            ),
            StreamBuilder<List<BlockedDetails>>(
              stream: UserStatusService().blockedUsers,
              initialData: UserStatusService().blockedUsers.value,
              builder: (context, snapshot) {
                List<BlockedDetails> blockedDetails = snapshot.data!;

                bool isBlocked =
                    blockedDetails.any((e) => e.blockedUid == widget.user.id!);

                return PopupMenuButton<int>(
                  color: Const.themeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Const.kLight,
                      width: 1,
                    ),
                  ),
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
                          textStyle: popupTextStyle,
                          value: 0,
                          child: Row(
                            children: [
                              Icon(Icons.person_off_outlined),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Engelle"),
                            ],
                          ),
                        ),
                      if (isBlocked)
                        PopupMenuItem(
                          textStyle: popupTextStyle,
                          value: 1,
                          child: Row(
                            children: [
                              Icon(Icons.person_outlined),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Engeli Kaldır"),
                            ],
                          ),
                        ),
                    ];
                  },
                );
              },
            ),
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

  Widget getUserNameWidget(bool isOnline) {
    List<Widget> children = [
      Hero(
        transitionOnUserGestures: true,
        tag: widget.user.id.toString() + "n",
        child: Material(
          color: Colors.transparent,
          textStyle: TextStyle(
            color: Const.contrainsColor,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
          child: Text(
            widget.user.userName ?? "User",
          ),
        ),
      ),
    ];
    if (isOnline) {
      children.add(
        Text(
          Const.timeEllapsed(widget.user.lastSeen!),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 350),
      child: Column(
        key: ValueKey(isOnline),
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isOnline ? MainAxisAlignment.center : MainAxisAlignment.spaceAround,
        children: children,
      ),
    );
  }

  TextStyle get popupTextStyle {
    return TextStyle(
      fontSize: 14,
      color: Const.contrainsColor,
    );
  }
}
