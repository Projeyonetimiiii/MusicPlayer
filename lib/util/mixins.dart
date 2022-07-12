import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onlinemusic/models/media_reference.dart';
import 'package:onlinemusic/models/usermodel.dart';
import 'package:onlinemusic/services/storage_bloc.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/enums.dart';
import 'package:onlinemusic/views/chat/messages/components/build_audio_widget.dart';
import 'package:onlinemusic/views/chat/messages/components/chat_input_field.dart';
import 'package:onlinemusic/widgets/build_item.dart';

mixin PickerMixin {
  Future<List<PlatformFile>> getImagePicker() async {
    FilePickerResult? images = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image);
    return images?.files ?? [];
  }

  Future<List<PlatformFile>> getAudioPicker() async {
    FilePickerResult? audio = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.audio,
    );
    return audio?.files ?? [];
  }

  Future<XFile?> getImagesPickerCamera() async {
    return ImagePicker().pickImage(source: ImageSource.camera);
  }
}

mixin BottomSheetMixin {
  Future<MediaReference?> getAudioModalBottomSheet(BuildContext context,
      FilesTyper filesTyper, UserModel? receiver, String myUid) async {
    bool loading = false;
    return await showModalBottomSheet<MediaReference>(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (c) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Const.themeColor,
            border: Border.all(
              color: Const.kLight,
              width: 1,
            ),
          ),
          margin: EdgeInsets.all(8),
          height: 200,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "'${filesTyper.files![0].name}' ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Const.contrainsColor,
                            ),
                          ),
                          TextSpan(
                            text: " ${receiver!.userName} ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Const.contrainsColor,
                            ),
                          ),
                          TextSpan(
                            text: "kişisine gönderilsin mi?",
                            style: TextStyle(
                              color: Const.contrainsColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    BuildAudioWidget(
                      audios: filesTyper.files ?? [],
                      size: MediaQuery.of(context).size,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("İptal Et"),
                              style: TextButton.styleFrom(
                                primary: Const.contrainsColor,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(33),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () async {
                                if (!loading) {
                                  setState(() {
                                    loading = true;
                                  });
                                  StorageBloc storageBloc = StorageBloc();
                                  MediaReference mediaRef =
                                      await storageBloc.uploadMessageAudio(
                                    index: 0,
                                    timeStamp: DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString(),
                                    ext: StorageBloc.fileExt(
                                        filesTyper.files![0].path!),
                                    file: File(filesTyper.files![0].path!),
                                    userUid: myUid,
                                  );
                                  Navigator.pop(context, mediaRef);
                                }
                              },
                              child:
                                  Text(loading ? "Gönderiliyor..." : "Gönder"),
                              style: TextButton.styleFrom(
                                primary: Const.contrainsColor,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(33),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

mixin LoadingMixin {
  void showLoadingStreamDialog(
      BuildContext context, Stream<double> loadingProgress) {
    showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          backgroundColor: Const.themeColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: StreamBuilder<double>(
            stream: loadingProgress,
            initialData: 0,
            builder: (context, snapshot) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Const.contrainsColor),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Resimler Yükleniyor ( %${(snapshot.data! * 100).toInt()} )",
                    style: TextStyle(
                      color: Const.contrainsColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

mixin BuildMediaItemMixin {
  Widget buildMusicItem(
    MediaItem item,
    List<MediaItem> queue, {
    VoidCallback? onPressed,
    Widget? trailing,
    BuildMusicListType type = BuildMusicListType.None,
  }) {
    return BuildItem(
      item: item,
      queue: queue,
      onPressed: onPressed,
      trailing: trailing,
      type: type,
    );
  }
}

mixin DialogMixin {
  Future<void> showTextDialog(
    String title,
    BuildContext context, {
    String? initialText,
    required ValueChanged<String> onSubmitted,
    String hintText = "Oynatma listesi ismi",
    String? submitText,
  }) async {
    TextEditingController controller = TextEditingController(text: initialText);
    await showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            autofocus: true,
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("İptal Et"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onSubmitted(controller.text.trim());
              },
              child: Text(submitText ?? "Kaydet"),
            ),
          ],
        );
      },
    );
  }
}
