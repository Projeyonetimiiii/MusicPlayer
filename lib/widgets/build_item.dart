import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:downloader/downloader.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/models/my_playlist.dart';
import 'package:onlinemusic/painters/progress_painter.dart';
import 'package:onlinemusic/services/download_service.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/enums.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/util/mixins.dart';
import 'package:onlinemusic/views/playing_screen/playing_screen.dart';
import 'package:onlinemusic/views/video_player_screen.dart';
import 'package:onlinemusic/widgets/my_overlay_notification.dart';
import 'package:share_plus/share_plus.dart';

class BuildItem extends StatefulWidget {
  const BuildItem({
    Key? key,
    required this.item,
    required this.queue,
    this.onPressed,
    this.trailing,
    this.type = BuildMusicListType.None,
  }) : super(key: key);

  final MediaItem item;
  final List<MediaItem> queue;

  final VoidCallback? onPressed;
  final Widget? trailing;
  final BuildMusicListType type;

  @override
  State<BuildItem> createState() => _BuildItemState();
}

class _BuildItemState extends State<BuildItem> with DialogMixin {
  double get progress {
    return downloadService.getProgress(widget.item);
  }

  bool downloading = false;

  bool get isDownloading {
    downloading = progress != 0;
    return downloading;
  }

  @override
  void initState() {
    downloadService.addListener(listener);
    super.initState();
  }

  @override
  void dispose() {
    downloadService.removeListener(listener);
    super.dispose();
  }

  listener() {
    if (downloadService.downloadingItem?.id == widget.item.id) {
      setState(() {});
    } else {
      if (downloading) {
        setState(() {
          downloading = false;
        });
      }
    }
  }

  MediaItem get item => widget.item;

  @override
  Widget build(BuildContext context) {
    Widget child = ListTile(
      leading: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 45.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: item.getImageWidget,
          ),
        ),
      ),
      title: Text(
        item.title.toString(),
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              item.artist.toString(),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
          Text(
            Const.getDurationString(item.duration ?? Duration.zero),
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
      trailing: widget.trailing ??
          PopupMenuButton<int>(
            onSelected: (s) {
              onSelected(s, item, context);
            },
            itemBuilder: (_) {
              return [
                if (widget.type.isQueue &&
                    item.id != handler.mediaItem.value?.id)
                  PopupMenuItem(
                    value: 0,
                    child: Row(
                      children: [
                        Icon(Icons.remove_rounded),
                        SizedBox(
                          width: 10,
                        ),
                        Text("Kuyruktan Çıkar")
                      ],
                    ),
                  ),
                if (handler.queue.value.isNotEmpty && !widget.type.isQueue)
                  PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(Icons.playlist_play_rounded),
                        SizedBox(
                          width: 10,
                        ),
                        Text("Sonrakini Çal")
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(Icons.playlist_add_rounded),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Oynatma Listesine Ekle")
                    ],
                  ),
                ),
                if (!widget.type.isQueue)
                  PopupMenuItem(
                    value: 3,
                    child: Row(
                      children: [
                        Icon(Icons.playlist_add_rounded),
                        SizedBox(
                          width: 10,
                        ),
                        Text("Kuyruğa Ekle")
                      ],
                    ),
                  ),
                if (item.type.isVideo) ...[
                  PopupMenuItem(
                    value: 4,
                    child: Row(
                      children: [
                        Icon(Icons.video_library_rounded),
                        SizedBox(
                          width: 10,
                        ),
                        Text("Video İzle")
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 5,
                    child: Row(
                      children: [
                        Icon(Icons.share),
                        SizedBox(
                          width: 10,
                        ),
                        Text("Paylaş")
                      ],
                    ),
                  ),
                ],
                if (widget.item.isOnline)
                  PopupMenuItem(
                    value: 6,
                    child: Row(
                      children: [
                        Icon(Icons.download_rounded),
                        SizedBox(
                          width: 10,
                        ),
                        Text("İndir")
                      ],
                    ),
                  ),
                if (widget.type.isDownloaded) ...[
                  PopupMenuItem(
                    value: 7,
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded),
                        SizedBox(
                          width: 10,
                        ),
                        Text("Cihazdan Sil")
                      ],
                    ),
                  ),
                ],
              ];
            },
          ),
      onTap: () async {
        if (widget.onPressed != null) {
          widget.onPressed!();
        } else {
          context.pushOpaque(
            PlayingScreen(
              queue: widget.queue,
              song: item,
            ),
          );
        }
      },
    );
    if (isDownloading) {
      child = Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: ProgressPainter(progress),
            ),
          ),
          child,
        ],
      );
    }

    return child;
  }

  void onSelected(int select, MediaItem item, BuildContext context) async {
    switch (select) {
      case 0:
        handler.removeQueueItem(item);
        break;
      case 1:
        if (handler.index + 1 <= handler.queue.value.length) {
          if (!handler.queue.value.any((element) => element.id == item.id)) {
            handler.insertQueueItem(handler.index + 1, item);
            showMessage(
              message: "\"" + item.title + "\" sonraki müzik olarak ayarlandı",
            );
          } else {
            showMessage(
              message: "\"" + item.title + "\" kuyrukta zaten mevcut",
            );
          }
        }
        break;
      case 2:
        MyPlaylist? playlist = await showModalBottomSheet<MyPlaylist>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.all(12),
                  constraints: BoxConstraints(
                    maxHeight: context.getSize.height * 0.7,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Const.kLight,
                      width: 1,
                    ),
                    color: Const.themeColor,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Oynatma Listesi Seçiniz",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (context.myData.getPlaylists.isEmpty) ...[
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: Text("Burada hiç liste yok"),
                          ),
                        ),
                      ],
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: context.myData.getPlaylists.map((e) {
                          return ListTile(
                            onTap: () {
                              Navigator.pop(ctx, e);
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
                                    ? e.songs.first.getImageWidget
                                    : Image.asset(
                                        "assets/images/default_song_image.png",
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            title: Text(e.name),
                            subtitle:
                                Text(e.songs.length.toString() + " Müzik"),
                          );
                        }).toList(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () async {
                              await showTextDialog(
                                "Oynatma Listesi Oluştur",
                                context,
                                onSubmitted: (s) {
                                  context.myData.addPlaylist(s.trim());
                                },
                              );
                              setState(() {});
                            },
                            child: Text("Yeni Bir Liste Oluştur"),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
        if (playlist != null) {
          if (!playlist.songs.any((element) => element.id == item.id)) {
            context.myData.updatePlaylist(
              playlist.copyWith(
                songs: playlist.songs..add(item),
              ),
            );
            showMessage(
              message:
                  "\"" + item.title + "\" ${playlist.name} listesine eklendi",
            );
            return;
          } else {
            showMessage(
              message: "\"" + item.title + "\" listede zaten mecut",
            );
          }
        }

        break;
      case 3:
        if (!handler.queue.value.any((element) => element.id == item.id)) {
          handler.addQueueItem(item);

          showMessage(
            message: "\"" + item.title + "\" kuyruğa eklendi",
          );
        } else {
          showMessage(
            message: "\"" + item.title + "\" kuyrukta zaten mevcut",
          );
        }
        break;
      case 4:
        String? url = await showDialog(
          context: context,
          builder: (ctx) {
            return FutureBuilder<String>(
              future: Const.getAudioUrlFromVideoId(item.id),
              builder: (context, snap) {
                if (snap.hasData) {
                  Navigator.pop(ctx, snap.data!);
                }
                return AlertDialog(
                  title: Text("Video Url'i Bulunuyor"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: CircularProgressIndicator(
                          color: Const.contrainsColor,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                          child:
                              Text("Video url'i bulunurken lütfen bekleyiniz"))
                    ],
                  ),
                );
              },
            );
          },
        );
        if (url != null) {
          context.push(VideoPlayerScreen(url: url, isLocal: false));
        } else {
          showMessage(
            message: "Video URL'i alınırken hata oluştu",
          );
        }
        break;
      case 5:
        Share.share('https://youtube.com/watch?v=${item.id}');
        break;
      case 6:
        bool isDownloaded = downloadService.isDownloaded(item);
        if (!isDownloaded) {
          downloadService.addQueue(item, context, isShowMessage: true);
        } else {
          showMessage(
            message: "Müzik önceden indirilmiş",
          );
        }
        break;
      case 7:
        await deleteFile(item.artUri?.toFilePath());
        String? filePath = await item.source;
        bool res = await deleteFile(filePath);
        if (res) {
          await Downloader().addToLibrary(filePath!);
          await downloadsBox!.delete(item.id);
          showMessage(
            message: "${item.title} Müziği Cihazdan Silindi",
          );
          List<MediaItem> items = context.myData.songs.value.toSet().toList();
          items.removeWhere((element) => element.id == item.id);
          context.myData.songs.add(items);
        }
        break;
      default:
    }
  }

  Future<bool> deleteFile(String? path) async {
    if (path != null) {
      try {
        File file = File(path);
        if (await file.exists()) {
          await file.delete();
          return true;
        }
      } on Exception catch (_) {}
    }
    return false;
  }
}
