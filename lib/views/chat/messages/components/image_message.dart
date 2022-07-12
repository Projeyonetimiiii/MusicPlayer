import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/views/chat/models/chat_message.dart';

class ImageMessage extends StatelessWidget {
  final ChatMessage message;
  const ImageMessage({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMee = message.senderId == FirebaseAuth.instance.currentUser!.uid;
    return Material(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        child: AspectRatio(
          aspectRatio: 1.6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: message.message!.isNotEmpty ? 0 : 2),
                      child: InkWell(
                        child: getImageWidget(
                          message,
                          FirebaseAuth.instance.currentUser!.uid,
                          message.message,
                        ),
                        onTap: () {},
                      ),
                    ),
                  ),
                  if (message.message!.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(5),
                      width: double.maxFinite,
                      color: Const.contrainsColor.withOpacity(isMee ? 1 : .1),
                      child: Text(
                        message.message!,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color:
                              isMee ? Const.themeColor : Const.contrainsColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getImageWidget(ChatMessage message, String myUid, String? mesaj) {
    bool noText = mesaj == null ? true : mesaj.isEmpty;
    List<String?> urls = message.images!.map((e) => e!.downloadURL).toList();

    return buildImageWidget(urls[0]!,
        tL: 8, tR: 8, bL: noText ? 8 : 0, bR: noText ? 8 : 0);
  }

  Widget buildImageWidget(String url,
      {double tR = 0, double tL = 0, double bR = 0, double bL = 0}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(bL),
          bottomRight: Radius.circular(bR),
          topLeft: Radius.circular(tL),
          topRight: Radius.circular(tR),
        ),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: CachedNetworkImageProvider(url),
        ),
      ),
    );
  }
}
