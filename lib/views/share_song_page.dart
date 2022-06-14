import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:icon_loading_button/icon_loading_button.dart';
import 'package:onlinemusic/models/audio.dart';
import 'package:onlinemusic/models/genre.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/category_sheet.dart';
import 'package:onlinemusic/widgets/custom_back_button.dart';
import 'package:onlinemusic/widgets/custom_textfield.dart';

import '../providers/data.dart';

class ShareSongPage extends StatefulWidget {
  ShareSongPage({Key? key}) : super(key: key);

  @override
  State<ShareSongPage> createState() => _ShareSongPageState();
}

class _ShareSongPageState extends State<ShareSongPage> {
  MediaItem? selectedSong;
  PageController pageController = PageController();
  List<Genre> genres = [];

  TextEditingController title = TextEditingController();
  TextEditingController artist = TextEditingController();
  IconButtonController controller = IconButtonController();

  late MyData data;

  @override
  void initState() {
    super.initState();
    data = context.myData;
    data.addListener(_listener);
  }

  @override
  void dispose() {
    data.removeListener(_listener);
    super.dispose();
  }

  void _listener() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Müzik Paylaş"),
        leading: CustomBackButton(),
      ),
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: pageController,
        children: [
          if (data.songs.isEmpty)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Hiç Müziğiniz Yok"),
              ],
            ),
          ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: data.songs.length,
              itemBuilder: (context, int index) {
                MediaItem music = data.songs[index];
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 5.0,
                  ),
                  child: ListTile(
                    leading: Container(
                      height: 50.0,
                      width: 50.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.grey.shade300,
                        //  image: DecorationImage(image:  FileImage())
                      ),
                      child: music.getImageWidget,
                      clipBehavior: Clip.antiAlias,
                    ),
                    title: Text(
                      music.title.toString(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      music.artist.toString(),
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () async {
                      setState(() {
                        selectedSong = music;
                        title.text = selectedSong!.title;
                        artist.text = selectedSong!.artist ?? "artist";
                      });
                      pageController.animateToPage(
                        1,
                        curve: Curves.linear,
                        duration: Duration(milliseconds: 350),
                      );
                    },
                  ),
                );
              }),
          Column(
            children: [
              Expanded(
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  children: [
                    Center(
                      child: SizedBox(
                        width: size.width / 1.5,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade300,
                            ),
                            child: selectedSong == null
                                ? Center(
                                    child: Text(""),
                                  )
                                : selectedSong!.getImageWidget,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                primary: Const.kBackground,
                                shape: RoundedRectangleBorder(),
                              ),
                              onPressed: () {
                                pageController.animateToPage(
                                  0,
                                  curve: Curves.linear,
                                  duration: Duration(milliseconds: 350),
                                );
                              },
                              child: Text("Müzik Seçimine Dön"),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: RawMaterialButton(
                        fillColor: Colors.grey.shade300,
                        elevation: 0,
                        focusElevation: 0,
                        hoverElevation: 0,
                        highlightElevation: 0,
                        onPressed: () async {
                          selectGenre();
                        },
                        child: genres.isEmpty
                            ? Text(
                                "Tür Seçiniz*",
                                style: TextStyle(
                                  color: Const.kBackground,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Wrap(
                                direction: Axis.horizontal,
                                children: genres.map((e) {
                                  return Container(
                                    margin: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(0),
                                      color: Colors.grey.shade300,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(e.name),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ),
                    CustomTextField(
                      hintText: "Başlık",
                      controller: title,
                    ),
                    CustomTextField(
                      hintText: "Sanatçı",
                      controller: artist,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: [
                    Expanded(
                      child: IconLoadingButton(
                        elevation: 0,
                        color: Const.kBackground,
                        width: MediaQuery.of(context).size.width - 10,
                        height: 45,
                        loaderSize: 45,
                        child: Text("Paylaş"),
                        iconData: Icons.share_rounded,
                        onPressed: () async {
                          controller.start();
                          try {
                            if (genres.isEmpty) {
                              await selectGenre();
                              if (genres.isEmpty) {
                                return;
                              }
                            }
                            await shareAudio(data);
                            controller.success();
                            Future.delayed(Duration(milliseconds: 500), () {
                              pageController.animateToPage(
                                0,
                                curve: Curves.linear,
                                duration: Duration(milliseconds: 350),
                              );
                            });
                          } on Exception catch (e) {
                            debugPrint(e.toString());
                            controller.error();
                          }
                        },
                        controller: controller,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String getNowMillisecondsSinceEpoch() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> shareAudio(MyData data) async {
    String? audioUrl;
    String? imagePath;
    String imageUrl;
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String timeStamp = getNowMillisecondsSinceEpoch();

    try {
      audioUrl = (await data.sB.uploadAudio(
              file: File(selectedSong!.extras!["url"]), userUid: userId))
          .downloadURL;
      if (audioUrl == null) {
        return;
      }
      print("AudioUrl: " + audioUrl);
    } on Exception catch (e) {
      debugPrint(e.toString());
      return;
    }

    imagePath = await data.saveImage(selectedSong!);

    if (imagePath != null) {
      String? uploadImageUrl =
          await data.sB.uploadImage(imagePath, userId, timeStamp: timeStamp);
      imageUrl = uploadImageUrl ?? Const.kDefaultImageUrl;
      print("İmageUrl: " + imageUrl);
    } else {
      imageUrl = Const.kDefaultImageUrl;
    }

    Audio audio = Audio(
      id: userId + timeStamp,
      title: title.text.trim(),
      artist: artist.text.trim(),
      url: audioUrl,
      image: imageUrl,
      genreIds: genres.map((e) => e.id).toList(),
      duration: selectedSong!.duration ?? Duration.zero,
      idOfTheSharingUser: userId,
    );

    bool res = await data.aB.saveAudioToFirebase(audio);
    if (res) {
      print("Yükleme başarılı");
    } else {
      print("Yükleme işlemi başarısız");
    }
  }

  Future<void> selectGenre() async {
    List<Genre>? genres = await showModalBottomSheet<List<Genre>>(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return CategoryPage(genres: this.genres);
        });
    if (genres != null) {
      setState(() {
        this.genres = genres;
      });
    }
  }
}
