import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/models/usermodel.dart';
import 'package:onlinemusic/services/auth.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/views/chat/models/chat.dart';

class ChatCard extends StatelessWidget {
  const ChatCard({
    Key? key,
    required this.chat,
    required this.press,
  }) : super(key: key);

  final Chat chat;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: AuthService().getUserStreamFromId(chat.userIds.firstWhere(
          (element) => element != FirebaseAuth.instance.currentUser!.uid)),
      builder: (context, snapshot) {
        UserModel? user;
        if (snapshot.hasData) {
          user = UserModel.fromMap(snapshot.data!.data()!);
        }
        return InkWell(
          onTap: press,
          child: Container(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                if (user == null) ...[
                  CircleAvatar(
                    radius: 45 / 2,
                    backgroundColor: Const.contrainsColor.withOpacity(0.1),
                  ),
                ],
                if (user != null) ...[
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Card(
                        elevation: 5,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23),
                        ),
                        child: SizedBox.square(
                          dimension: 45,
                          child: Hero(
                            tag: (user.id.toString()) + "i",
                            child: Material(
                              elevation: 0,
                              clipBehavior: Clip.antiAlias,
                              shape: StadiumBorder(),
                              child: CachedNetworkImage(
                                imageUrl: user.image!,
                                fit: BoxFit.cover,
                                placeholder: (c, i) {
                                  return CircleAvatar(
                                    backgroundColor:
                                        Const.contrainsColor.withOpacity(0.1),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Hero(
                                tag: (user?.id.toString() ??
                                        DateTime.now()
                                            .microsecondsSinceEpoch
                                            .toString()) +
                                    "n",
                                child: Material(
                                  color: Colors.transparent,
                                  child: Text(
                                    user?.userName ?? "User",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                chat.message.message ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Opacity(
                              opacity: 0.64,
                              child: Text(
                                Const.timeEllapsed(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    chat.message.messageTime!,
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
