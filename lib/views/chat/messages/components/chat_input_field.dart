import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/views/chat/models/chat_message.dart';
import 'package:onlinemusic/views/chat/models/sender_media_message.dart';

import '../../../../enums/enums.dart';

class ChatInputField extends StatefulWidget {
  const ChatInputField({
    Key? key,
    required this.rUid,
  }) : super(key: key);
  final String rUid;

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  TextEditingController message = TextEditingController();
  bool loading = false;
  String? docId;
  bool didIBlock = false;
  bool didHeBlock = false;
  @override
  Widget build(BuildContext context) {
    
    return Column(
      children: [
        Divider(
          height: 1,
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SafeArea(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  child: TextButton(
                    child: Icon(Icons.add, color: Colors.black),
                    onPressed: () async {},
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: message,
                            cursorRadius: Radius.circular(8),
                            cursorColor:
                                Theme.of(context).textTheme.bodyText1!.color,
                            cursorWidth: 1.5,
                            decoration: InputDecoration(
                              hintText: "Mesajınız...",
                              border: InputBorder.none,
                            ),
                            onChanged: (s) {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    if (this.message.text.trim().isNotEmpty) {
                      String senderId = FirebaseAuth.instance.currentUser!.uid;
                      ChatMessage message = ChatMessage(
                        message: this.message.text.trim(),
                        messageStatus: MessageStatus.Sended,
                        messageTime: DateTime.now().millisecondsSinceEpoch,
                        senderId: senderId,
                        messageType: ChatMessageType.Text,
                        receiverId: widget.rUid,
                      );
                     
                      this.message.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<SenderMediaMessage?> getFilesDetailsScreen(
      FilesTyper filesTyper, String myUid) async {
    switch (filesTyper.type) {
      case ChatMessageType.Image:

      case ChatMessageType.Audio:

      default:
        return null;
    }
  }

  FutureOr<FilesTyper?> showModal() async {
    return await showModalBottomSheet<FilesTyper>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (c) {
        return Container(
          width: double.maxFinite,
          margin: EdgeInsets.all(8),
          height: 250,
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 3),
                child: Text(
                  "Dosya Türü Seçin",
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.white60,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(3))),
                width: 150,
                height: 3,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    dosyaTipleri(
                      "Galeri",
                      Icons.photo_outlined,
                      imagePicker: true,
                      onPressed: () async {},
                    ),
                    dosyaTipleri("Kamera", Icons.camera_alt_outlined,
                        imagePicker: true, onPressed: () async {}),
                    dosyaTipleri("Ses", Icons.headset_outlined,
                        onPressed: () async {}),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Column dosyaTipleri(
    String isim,
    IconData icon, {
    bool imagePicker = false,
    VoidCallback? onPressed,
  }) {
    return Column(
      children: <Widget>[
        Container(
          color: Colors.transparent,
          height: 55,
          width: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.grey[850],
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(45)),
            ),
            onPressed: onPressed,
            child: Center(
              child: Icon(
                icon,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 5,
          ),
          child: Text(
            isim,
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
          ),
        ),
      ],
    );
  }
}

class FilesTyper {
  FilesTyper({this.files, this.type});

  final ChatMessageType? type;
  final List<PlatformFile>? files;
}
