import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:onlinemusic/models/media_reference.dart';
import 'package:onlinemusic/models/usermodel.dart';
import 'package:onlinemusic/services/storage_bloc.dart';
import 'package:onlinemusic/views/chat/messages/components/build_audio_widget.dart';
import 'package:onlinemusic/views/chat/messages/components/chat_input_field.dart';

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

  Future<Media?> getImagesPickerCamera() async {
    Media? media = await ImagePickers.openCamera(
      cameraMimeType: CameraMimeType.photo,
    );

    return media;
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
                color: Colors.grey[850]),
            margin: EdgeInsets.all(8),
            height: 200,
            child: StatefulBuilder(builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: "'${filesTyper.files![0].name}' ",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: " ${receiver!.userName} ",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: "kişisine gönderilsin mi?"),
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
                                primary: Colors.white,
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
                                      await storageBloc.uploadAudio(
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
                                  primary: Colors.white,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(33))),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // TextButton(onPressed:(){}, child: Text("Göder")),
                  ],
                ),
              );
            }),
          );
        });
  }
}

mixin LoadingMixin {
  void showLoadingStreamDialog(
      BuildContext context, Stream<double> loadingProgress) {
    showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            backgroundColor: Colors.grey.shade800,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            content: StreamBuilder<double>(
                stream: loadingProgress,
                initialData: 0,
                builder: (context, snapshot) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                          "Resimler Yükleniyor ( %${(snapshot.data! * 100).toInt()} )",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ],
                  );
                }),
          );
        });
  }

  void showLoadingDialog(BuildContext context, String textLoading) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (c) {
          return AlertDialog(
            backgroundColor: Colors.grey.shade800,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                SizedBox(
                  width: 10,
                ),
                Text("$textLoading Yükleniyor",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        });
  }
}
