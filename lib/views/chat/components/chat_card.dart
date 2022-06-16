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
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: press,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade500.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    if (user == null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          width: 45,
                          height: 45,
                          color: Colors.black26,
                        ),
                      ),
                    ],
                    if (user != null) ...[
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              width: 45,
                              height: 45,
                              child: CachedNetworkImage(
                                imageUrl: user.image!,
                                fit: BoxFit.cover,
                                placeholder: (c, i) {
                                  return Container(
                                    width: 45,
                                    height: 45,
                                    color: Colors.black26,
                                  );
                                },
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
                            Text(
                              user?.userName ?? "User",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 8),
                            Opacity(
                              opacity: 0.64,
                              child: Text(
                                chat.message.message ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: 0.64,
                      child: Text(Const.getDateTimeString(
                        DateTime.fromMillisecondsSinceEpoch(
                          chat.message.messageTime!,
                        ),
                      ).toString()),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
