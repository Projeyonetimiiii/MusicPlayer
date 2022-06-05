import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/views/chat/models/chat_message.dart';

class ImageMessage extends StatelessWidget {
  final ChatMessage message;
  const ImageMessage({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.60, // 55% of total width
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
                        top: 2,
                        right: 2,
                        left: 2,
                        bottom: message.message!.isNotEmpty ? 0 : 2),
                    child: InkWell(
                      child: getImageWidget(
                          message,
                          FirebaseAuth.instance.currentUser!.uid,
                          message.message),
                      onTap: () {},
                    ),
                  ),
                ),
                if (message.message!.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(5),
                    width: double.maxFinite,
                    child: Text(
                      message.message!,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getImageWidget(ChatMessage message, String myUid, String? mesaj) {
    bool noText = mesaj == null ? true : mesaj.isEmpty;
    List<String?> urls = message.images!.map((e) => e!.downloadURL).toList();
    switch (urls.length) {
      case 1:
        return buildImageWidget(urls[0]!,
            tL: 8, tR: 8, bL: noText ? 8 : 0, bR: noText ? 8 : 0);
      default:
        return buildImageWidget(urls[0]!,
            tL: 8, tR: 8, bL: noText ? 8 : 0, bR: noText ? 8 : 0);
    }
    // case 2:
    //   return Row(
    //     children: [
    //       buildImageWidget(urls[0]!, tL: 8, bL: noText ? 8 : 0),
    //       verticalDivider(message.sender!.uid, myUid),
    //       buildImageWidget(urls[1]!, tR: 8, bR: noText ? 8 : 0),
    //     ],
    //   );
    // case 3:
    //   return Row(
    //     children: [
    //       Expanded(
    //         child: Column(
    //           children: [
    //             buildImageWidget(urls[0]!, tL: 8),
    //             horizontalDivider(message.sender!.uid, myUid),
    //             buildImageWidget(urls[1]!, bL: noText ? 8 : 0),
    //           ],
    //         ),
    //       ),
    //       verticalDivider(message.sender!.uid, myUid),
    //       buildImageWidget(urls[2]!, tR: 8, bR: noText ? 8 : 0),
    //     ],
    //   );
    //   default:
    //     int overCount = urls.length - 4;
    //     return Stack(
    //       children: [
    //         Column(
    //           children: [
    //             Expanded(
    //               child: Row(
    //                 children: [
    //                   buildImageWidget(urls[0]!, tL: 8),
    //                   verticalDivider(message.sender!.uid, myUid),
    //                   buildImageWidget(urls[1]!, tR: 8),
    //                 ],
    //               ),
    //             ),
    //             horizontalDivider(message.sender!.uid, myUid),
    //             Expanded(
    //               child: Row(
    //                 children: [
    //                   buildImageWidget(urls[2]!, bL: noText ? 8 : 0),
    //                   verticalDivider(message.sender!.uid, myUid),
    //                   buildImageWidget(urls[3]!, bR: noText ? 8 : 0),
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //         if (urls.length > 4)
    //           Center(
    //             child: Container(
    //               width: 30,
    //               height: 30,
    //               padding: EdgeInsets.all(3),
    //               decoration: BoxDecoration(
    //                   borderRadius: BorderRadius.circular(90),
    //                   color: getMessageColor(message.sender!.uid, myUid)),
    //               child: Center(
    //                 child: Text(
    //                   "+${overCount > 9 ? 9 : overCount}",
    //                   style: TextStyle(
    //                       color:
    //                           getMessageTextColor(message.sender!.uid, myUid),
    //                       fontWeight: FontWeight.bold),
    //                 ),
    //               ),
    //             ),
    //           ),
    //       ],
    //     );
    // }
  }

  Expanded buildImageWidget(String url,
      {double tR = 0, double tL = 0, double bR = 0, double bL = 0}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(bL),
            bottomRight: Radius.circular(bR),
            topLeft: Radius.circular(tL),
            topRight: Radius.circular(tR),
          ),
          image: DecorationImage(fit: BoxFit.cover, image: NetworkImage(url)),
        ),
      ),
    );
  }

  Widget verticalDivider(String? sUid, String myUid) {
    return Container(
      width: 2,
      height: double.maxFinite,
      color: getMessageColor(),
    );
  }

  Widget horizontalDivider(String? sUid, String myUid) {
    return Container(
      width: double.maxFinite,
      height: 2,
      color: getMessageColor(),
    );
  }
}

getMessageColor() {
  return Colors.white;
}
