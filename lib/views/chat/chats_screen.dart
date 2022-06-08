import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/models/usermodel.dart';
import 'package:onlinemusic/services/auth.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/chat/components/chat_card.dart';
import 'package:onlinemusic/views/chat/messages/message_screen.dart';
import 'package:onlinemusic/views/chat/models/chat.dart';

class ChatsScreen extends StatefulWidget {
  ChatsScreen({Key? key}) : super(key: key);
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Center(
          child: Container(
            width: 40,
            height: 40,
            margin: EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                fit: BoxFit.cover,
                image:
                    NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!),
              ),
            ),
          ),
        ),
        title: Text(
          "Mesajlar",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<Chat>>(
       
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text("Yükleniyor..."),
            );
          }

          List<Chat> chats = snapshot.data ?? [];
          if (chats.isEmpty) {
            return Center(
              child: Text("Yokki..."),
            );
          }
          return ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              return ChatCard(
                chat: chats[index],
                press: () async {
                  UserModel? user = await AuthService().getUserFromId(
                      chats[index].userIds.firstWhere((element) =>
                          element != FirebaseAuth.instance.currentUser!.uid));
                  if (user != null) {
                    context.push(
                      MessagesScreen(
                        user: user,
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
