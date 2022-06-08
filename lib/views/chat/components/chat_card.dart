import 'package:flutter/material.dart';
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
              // BuildUserImageAndIsOnlineWidget(
              //   usersBlock: usersBlock,
              //   uid: chat.senderUid == userBlock.user!.uid
              //       ? chat.rUid
              //       : chat.senderUid,
              //   width: 45,
              // ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat.message.messageType.toString(),
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
              /*  chat.unReadCount==0 ? */
              Opacity(
                opacity: 0.64,
                child: Text(DateTime.fromMillisecondsSinceEpoch(
                        chat.message.messageTime!)
                    .toString()),
              ),
              // :Column(
              //   crossAxisAlignment: CrossAxisAlignment.end,
              //   children: [
              //      Opacity(
              //   opacity: 0.64,
              //   child: Text(chat.time.toString()),
              // ),
              // SizedBox(height: 2,),
              // Container(
              //   constraints: BoxConstraints(minWidth:20),
              //   padding: EdgeInsets.all(2),
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(4),
              //     color: kPrimaryColor.withOpacity(0.5)
              //   ),
              //   child: Center(child: Text(chat.unReadCount.toString(),style: TextStyle(color: Colors.black54),),),
              // ),
              //     ],
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
