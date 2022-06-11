import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:onlinemusic/models/blocked_details.dart';
import 'package:onlinemusic/models/media_reference.dart';
import 'package:onlinemusic/models/usermodel.dart';
import 'package:onlinemusic/services/messages_service.dart';
import 'package:onlinemusic/services/user_status_service.dart';
import 'package:onlinemusic/util/enums.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/util/mixins.dart';
import 'package:onlinemusic/views/chat/models/chat_message.dart';
import 'package:onlinemusic/views/chat/models/sender_media_message.dart';
import 'package:onlinemusic/views/details_screen/images_details.dart';

class ChatInputField extends StatefulWidget {
  const ChatInputField({
    Key? key,
    required this.rUser,
  }) : super(key: key);
  final UserModel rUser;

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField>
    with PickerMixin, BottomSheetMixin {
  TextEditingController message = TextEditingController();
  String? docId;
  bool didIBlock = false;
  bool didHeBlock = false;
  @override
  Widget build(BuildContext context) {
    docId = messagesService.getDoc(
        widget.rUser.id, FirebaseAuth.instance.currentUser!.uid);
    return StreamBuilder<List<BlockedDetails>>(
        stream: UserStatusService().blockedUsers,
        initialData: UserStatusService().blockedUsers.value,
        builder: (context, myBlockedUsers) {
          didIBlock =
              myBlockedUsers.data!.any((e) => e.blockedUid == widget.rUser.id);
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: UserStatusService().streamBlockedUsers(widget.rUser.id!),
              builder: (context, recBlockedUsers) {
                if (recBlockedUsers.hasData) {
                  List<BlockedDetails> heBlockedDetails = recBlockedUsers
                      .data!.docs
                      .map((e) => BlockedDetails.fromMap(e.data()))
                      .toList();
                  didHeBlock = heBlockedDetails.any((e) =>
                      e.blockedUid == FirebaseAuth.instance.currentUser!.uid);
                } else {
                  didHeBlock = false;
                }
                return Stack(
                  children: [
                    Column(
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
                                    onPressed: () async {
                                      FilesTyper? filesType = await showModal();
                                      if (filesType != null) {
                                        SenderMediaMessage? senderMediaMessage =
                                            await getFilesDetailsScreen(
                                                filesType,
                                                FirebaseAuth
                                                    .instance.currentUser!.uid);
                                        if (senderMediaMessage != null) {
                                          MessagesService service =
                                              MessagesService.instance;
                                          await service.addMessage(
                                            FirebaseAuth
                                                .instance.currentUser!.uid,
                                            widget.rUser.id!,
                                            ChatMessage(
                                              audio: senderMediaMessage.type ==
                                                      ChatMessageType.Audio
                                                  ? senderMediaMessage
                                                      .refs!.first
                                                  : null,
                                              images: senderMediaMessage.type ==
                                                      ChatMessageType.Image
                                                  ? senderMediaMessage.refs!
                                                  : null,
                                              isRemoved: false,
                                              receiverId: widget.rUser.id!,
                                              senderId: FirebaseAuth
                                                  .instance.currentUser!.uid,
                                              messageStatus:
                                                  MessageStatus.Sended,
                                              messageType:
                                                  senderMediaMessage.type,
                                              messageTime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              message:
                                                  senderMediaMessage.message,
                                            ),
                                          );
                                        }
                                      }
                                    },
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
                                            cursorColor: Theme.of(context)
                                                .textTheme
                                                .bodyText1!
                                                .color,
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
                                      String senderId = FirebaseAuth
                                          .instance.currentUser!.uid;
                                      ChatMessage message = ChatMessage(
                                        message: this.message.text.trim(),
                                        messageStatus: MessageStatus.Sended,
                                        messageTime: DateTime.now()
                                            .millisecondsSinceEpoch,
                                        senderId: senderId,
                                        messageType: ChatMessageType.Text,
                                        receiverId: widget.rUser.id,
                                      );
                                      await messagesService.addMessage(
                                          senderId, widget.rUser.id!, message);
                                      this.message.clear();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (didHeBlock)
                      Positioned(
                        top: 1,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: Center(
                            child: Text(
                              "Görünüşe göre ${widget.rUser.userName} sizi engellemiş.",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    if (didIBlock)
                      Positioned(
                        top: 1,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Bu kullanıcıyı engellediniz.",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              TextButton(
                                  style: TextButton.styleFrom(
                                      shape: StadiumBorder(
                                        side: BorderSide(
                                          color: Colors.white30,
                                        ),
                                      ),
                                      primary: Colors.white),
                                  onPressed: () async {
                                    UserStatusService()
                                        .deleteBlockedUser(widget.rUser.id!);
                                  },
                                  child: Text("Engeli Kaldır")),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              });
        });
  }

  Future<SenderMediaMessage?> getFilesDetailsScreen(
      FilesTyper filesTyper, String myUid) async {
    switch (filesTyper.type) {
      case ChatMessageType.Image:
        return context.push(
          ImagesDetail(
            files: filesTyper.files,
            receiver: widget.rUser,
          ),
        );

      case ChatMessageType.Audio:
        if (filesTyper.files!.isNotEmpty) {
          MediaReference? mediaRef = await getAudioModalBottomSheet(
            context,
            filesTyper,
            widget.rUser,
            myUid,
          );
          return mediaRef != null
              ? SenderMediaMessage(
                  type: ChatMessageType.Audio, message: "", refs: [mediaRef])
              : null;
        } else
          return null;
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
          height: 150,
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
                      onPressed: () async {
                        List<PlatformFile> files = await getImagePicker();
                        if (files.isNotEmpty) {
                          Navigator.pop(
                            context,
                            FilesTyper(
                              files: files,
                              type: ChatMessageType.Image,
                            ),
                          );
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    dosyaTipleri("Kamera", Icons.camera_alt_outlined,
                        imagePicker: true, onPressed: () async {
                      Media? image = await getImagesPickerCamera();
                      PlatformFile imagesPlat;
                      if (image != null) {
                        int size = 0;
                        try {
                          File file = File(image.path!);
                          size = await file.length();
                        } on Exception catch (_) {}
                        imagesPlat = PlatformFile(
                          size: size,
                          path: image.path,
                          name: image.path ?? "MediaName",
                        );
                        Navigator.pop(
                          context,
                          FilesTyper(
                            files: [imagesPlat],
                            type: ChatMessageType.Image,
                          ),
                        );
                      } else
                        Navigator.pop(context);
                    }),
                    dosyaTipleri("Ses", Icons.headset_outlined,
                        onPressed: () async {
                      List<PlatformFile> files = await getAudioPicker();
                      if (files.isNotEmpty) {
                        Navigator.pop(
                          context,
                          FilesTyper(
                            files: files,
                            type: ChatMessageType.Audio,
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    }),
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
