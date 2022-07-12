import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:onlinemusic/models/my_playlist.dart';
import 'package:onlinemusic/providers/data.dart';
import 'package:onlinemusic/services/search_service.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/util/mixins.dart';
import 'package:onlinemusic/views/my_playlist_details.dart';
import 'package:onlinemusic/views/playing_screen/playing_screen.dart';
import 'package:onlinemusic/views/playlist_screen/widgets/change_image_controller.dart';
import 'package:onlinemusic/views/playlist_screen/widgets/playlist_change_image.dart';
import 'package:onlinemusic/widgets/custom_back_button.dart';
import 'package:onlinemusic/widgets/mini_player.dart';
import 'package:onlinemusic/widgets/my_overlay_notification.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PlaylistsScreen extends StatefulWidget {
  PlaylistsScreen({Key? key}) : super(key: key);

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> with DialogMixin {
  MyData get data => context.myData;

  late ChangeImageController controller;

  @override
  void initState() {
    controller = ChangeImageController();
    controller.startTimer();
    super.initState();
  }

  @override
  void dispose() {
    controller.stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        title: Text("Oynatma Listeleri"),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  ListTile(
                    leading: SizedBox.square(
                      dimension: 50,
                      child: Center(
                        child: Icon(Icons.add_rounded),
                      ),
                    ),
                    title: Text("Oynatma Listesi Oluştur"),
                    onTap: () {
                      showTextDialog(
                        "Oynatma Listesi Oluştur",
                        context,
                        onSubmitted: (s) {
                          context.myData.addPlaylist(s.trim());
                        },
                      );
                    },
                  ),
                  ListTile(
                    leading: SizedBox.square(
                      dimension: 50,
                      child: Center(
                        child: Icon(MdiIcons.youtube),
                      ),
                    ),
                    title: Text("Youtube'den İçeri Aktar"),
                    onTap: () {
                      showTextDialog(
                        "Oynatma listesi linki",
                        context,
                        hintText: "Oynatma listesi linki",
                        onSubmitted: (value) async {
                          String? message = await showDialog<String>(
                            context: context,
                            builder: (ctx) {
                              return FutureBuilder<MyPlaylist?>(
                                future:
                                    SearchService.getMyPlaylistFromUrl(value),
                                builder: (c, snap) {
                                  if (snap.hasError) {
                                    Navigator.pop(ctx, snap.error.toString());
                                  }
                                  if (snap.hasData) {
                                    if (snap.data != null) {
                                      ctx.myData.addPlaylistFromMyPlaylist(
                                          snap.data!);
                                      Navigator.pop(ctx,
                                          "\"${snap.data!.name}\" listesi içe aktarıldı");
                                    } else {
                                      Navigator.pop(
                                          ctx, "Liste içe aktarılamadı");
                                    }
                                  }
                                  return SimpleDialog(
                                    title: Text(
                                      "Lütfen Bekleyiniz",
                                    ),
                                    children: [
                                      Center(
                                        child: CircularProgressIndicator(
                                          color: Const.contrainsColor,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                          showMessage(
                            message: message ?? "",
                          );
                        },
                      );
                    },
                  ),
                  ListTile(
                    leading: SizedBox.square(
                      dimension: 50,
                      child: Center(
                        child: Icon(Icons.search_rounded),
                      ),
                    ),
                    title: Text("Youtube'den Liste Ara"),
                    onTap: () {
                      showTextDialog(
                        "Liste İsmi",
                        context,
                        hintText: "Liste İsmi",
                        submitText: "Ara",
                        onSubmitted: (s) async {
                          String url = Const.getPlaylistsUrl(s.trim());
                          if (await canLaunchUrlString(url)) {
                            await launchUrl(Uri.parse(url),
                                mode: LaunchMode.externalApplication);
                          }
                        },
                      );
                    },
                  ),
                  StreamBuilder<List<MyPlaylist>>(
                    stream: data.myPlaylists,
                    initialData: data.myPlaylists.value,
                    builder: (context, snapshot) {
                      if (snapshot.data!.length < 2) {
                        return SizedBox();
                      }
                      return ListTile(
                        leading: SizedBox.square(
                          dimension: 50,
                          child: Center(
                            child: Icon(Icons.merge_type_rounded),
                          ),
                        ),
                        title: Text("Oynatma listelerini birleştir"),
                        onTap: () {
                          showMergeDialog();
                        },
                      );
                    },
                  ),
                  StreamBuilder<List<MyPlaylist>>(
                    stream: data.myPlaylists,
                    initialData: data.myPlaylists.value,
                    builder: (c, snap) {
                      List<MyPlaylist> lists = snap.data!;
                      return Column(
                        children: lists.map((e) {
                          return ListTile(
                            onTap: () {
                              context.push(MyPlaylistDetails(playlist: e));
                            },
                            leading: SizedBox.square(
                              dimension: 50,
                              child: Card(
                                elevation: 5,
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: e.songs.isNotEmpty
                                    ? PlaylistChangeImage(
                                        controller: controller,
                                        playlist: e,
                                      )
                                    : Image.asset(
                                        "assets/images/default_song_image.png",
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            title: Text(
                              e.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle:
                                Text(e.songs.length.toString() + " Müzik"),
                            trailing: PopupMenuButton(
                              icon: const Icon(Icons.more_vert_rounded),
                              onSelected: (int? value) async {
                                switch (value) {
                                  case 0:
                                    showTextDialog(
                                      "Yeniden Adlandır",
                                      context,
                                      initialText: e.name,
                                      onSubmitted: (s) {
                                        data.updatePlaylist(e.copyWith(name: s),
                                            checkName: true);
                                      },
                                    );
                                    break;
                                  case 1:
                                    context.pushOpaque(
                                      PlayingScreen(
                                        song: e.songs.first,
                                        queue: e.songs,
                                      ),
                                    );
                                    break;
                                  case 2:
                                    deletePlaylist(e);
                                    break;
                                  default:
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 0,
                                  child: Row(
                                    children: [
                                      const Icon(
                                          Icons.drive_file_rename_outline),
                                      const SizedBox(width: 10.0),
                                      Text("Yeniden Adlandır"),
                                    ],
                                  ),
                                ),
                                if (e.songs.isNotEmpty)
                                  PopupMenuItem(
                                    value: 1,
                                    child: Row(
                                      children: [
                                        const Icon(Icons.play_arrow_rounded),
                                        const SizedBox(width: 10.0),
                                        Text("Oynat"),
                                      ],
                                    ),
                                  ),
                                PopupMenuItem(
                                  value: 2,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.delete_outline_rounded),
                                      const SizedBox(width: 10.0),
                                      Text("Sil"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          MiniPlayer(),
        ],
      ),
    );
  }

  void deletePlaylist(MyPlaylist playlist) {
    showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          title: Text("Emin misin?"),
          content: Text.rich(
            TextSpan(
              text: "\"${playlist.name}\"",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Const.contrainsColor,
              ),
              children: [
                TextSpan(
                  text: " listesini silmek istediğine emin misin?",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Const.contrainsColor,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Hayır"),
            ),
            TextButton(
              onPressed: () {
                data.removePlaylist(playlist);
                Navigator.pop(context);
              },
              child: Text("Evet"),
            ),
          ],
        );
      },
    );
  }

  void showMergeDialog() {
    showDialog(
      context: context,
      builder: (c) {
        List<MyPlaylist> selectedList = [];
        MyPlaylist? mergePlaylist;
        return AlertDialog(
          title: Text("Birleştir"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: data.getPlaylists.map((e) {
                        return CheckboxListTile(
                          checkColor: Const.themeColor,
                          activeColor: Const.contrainsColor,
                          tileColor: mergePlaylist?.name == e.name
                              ? Const.contrainsColor.withOpacity(0.1)
                              : Colors.transparent,
                          value: selectedList
                              .any((element) => element.name == e.name),
                          onChanged: (d) {
                            d = d ?? false;
                            if (!d) {
                              selectedList.removeWhere(
                                  (element) => element.name == e.name);
                            } else {
                              selectedList.add(e);
                            }
                            try {
                              mergePlaylist = selectedList.first;
                            } on StateError catch (_) {
                              mergePlaylist = null;
                            }
                            setState(() {});
                          },
                          title: Text(e.name),
                          controlAffinity: ListTileControlAffinity.trailing,
                        );
                      }).toList(),
                    ),
                    // Divider(
                    //   color: Const.contrainsColor.withOpacity(0.2),
                    //   thickness: 1,
                    // ),
                    // ListTile(
                    //   title: Text("Birleştirilenleri sil"),
                    //   trailing: Transform.scale(
                    //     scale: 0.7,
                    //     child: CupertinoSwitch(
                    //       activeColor: Const.contrainsColor,
                    //       value: mergeRemove,
                    //       onChanged: (s) {
                    //         setState(() {
                    //           mergeRemove = !mergeRemove;
                    //         });
                    //       },
                    //     ),
                    //   ),
                    //   onTap: () {
                    //     setState(() {
                    //       mergeRemove = !mergeRemove;
                    //     });
                    //   },
                    // ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                showTextDialog(
                  "Oynatma Listesi Oluştur",
                  context,
                  onSubmitted: (s) {
                    List<MediaItem> allItems = [];
                    for (var list in selectedList) {
                      allItems.addAll(list.songs
                          .where((element) => !allItems
                              .any((element2) => element.id == element2.id))
                          .toList());
                      data.removePlaylist(list);
                    }
                    MyPlaylist playlist = MyPlaylist(
                        createdDate: DateTime.now(), name: s, songs: allItems);
                    context.myData.addPlaylistFromMyPlaylist(playlist);
                  },
                );
              },
              child: Text("Yeni Listeye Kaydet"),
            ),
            TextButton(
              onPressed: () {
                if (selectedList.isNotEmpty) {
                  if (mergePlaylist != null) {
                    List<MediaItem> allItems = [];

                    for (var list in selectedList) {
                      allItems.addAll(list.songs
                          .where((element) => !allItems
                              .any((element2) => element.id == element2.id))
                          .toList());
                      if (list.name != mergePlaylist!.name) {
                        data.removePlaylist(list);
                      }
                    }

                    data.updatePlaylist(mergePlaylist!.copyWith(
                      songs: allItems,
                    ));
                  }
                }
                Navigator.pop(context);
              },
              child: Text("Üzerine Yaz"),
            ),
          ],
        );
      },
    );
  }
}
