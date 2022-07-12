import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/services/download_service.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/converter.dart';
import 'package:onlinemusic/util/enums.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/util/helper_functions.dart';
import 'package:onlinemusic/util/mixins.dart';
import 'package:onlinemusic/views/playing_screen/playing_screen.dart';
import 'package:onlinemusic/widgets/build_media_items.dart';
import 'package:onlinemusic/widgets/custom_back_button.dart';
import 'package:onlinemusic/widgets/mini_player.dart';
import 'package:onlinemusic/widgets/my_dismissible.dart';
import 'package:onlinemusic/widgets/my_overlay_notification.dart';
import 'package:onlinemusic/widgets/short_popupbutton.dart';

class DonwnloadedScreen extends StatefulWidget {
  static bool isRunning = false;
  // final String? itemId;
  DonwnloadedScreen({
    Key? key,
    // this.itemId,
  }) : super(key: key);

  @override
  State<DonwnloadedScreen> createState() => _DonwnloadedScreenState();
}

class _DonwnloadedScreenState extends State<DonwnloadedScreen> {
  SortType? sortType;
  OrderType? orderType;
  // String? itemId;

  @override
  void initState() {
    DonwnloadedScreen.isRunning = true;
    // itemId = widget.itemId;
    super.initState();
  }

  @override
  void dispose() {
    DonwnloadedScreen.isRunning = false;
    super.dispose();
  }

  int get downloadedCount {
    return downloadsBox!.values.toList().length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        title: StreamBuilder(
            stream: downloadsBox!.watch().distinct(),
            builder: (context, snapshot) {
              return Text(
                  "İndirilenler ${downloadedCount == 0 ? "" : "($downloadedCount)"}");
            }),
        actions: [
          IconButton(
            onPressed: () {
              context.push(DownloadQueue());
            },
            icon: Icon(Icons.queue_music_rounded),
          ),
          SortPopupButton(
            isDownload: true,
            changeSort: (sort, order) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                setState(() {
                  sortType = sort;
                  orderType = order;
                });
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<BoxEvent>(
              stream: downloadsBox!.watch().distinct(),
              builder: (c, snap) {
                List downloadedSongs = downloadsBox!.values.toList();
                if (downloadedSongs.isEmpty) {
                  return Center(
                    child: Text("Burada Hiçbirşey Yok"),
                  );
                }
                List<MediaItem> items = downloadedSongs
                    .map((e) => MediaItemConverter.jsonToMediaItem(e))
                    .toList();
                if (sortType == null && orderType == null) {
                  items = sortItems(items, SortType.Name, OrderType.Growing);
                } else {
                  items = sortItems(items, sortType!, orderType!);
                }
                return BuildMediaItems(
                  items: items,
                  type: BuildMusicListType.Downloaded,
                  builder: (child, item) {
                    return MyDismissible(
                      key: ValueKey(item.id),
                      child: child,
                      onDismissed: (s) {
                        downloadsBox!.delete(item.id);
                      },
                    );
                  },
                );
              },
            ),
          ),
          MiniPlayer(),
        ],
      ),
    );
  }
}

class DownloadQueue extends StatefulWidget {
  DownloadQueue({Key? key}) : super(key: key);

  @override
  State<DownloadQueue> createState() => _DownloadQueueState();
}

class _DownloadQueueState extends State<DownloadQueue>
    with BuildMediaItemMixin {
  String? lastDownloadingItem;
  List<MediaItem> queue = [];

  @override
  void initState() {
    downloadService.addListener(listener);
    queue = downloadService.downloadQueue.toSet().toList();
    super.initState();
  }

  void listener() {
    if (lastDownloadingItem != downloadService.downloadingItem?.id) {
      setState(() {});
    } else if (!listEquals(queue, downloadService.downloadQueue)) {
      queue = downloadService.downloadQueue.toSet().toList();
      setState(() {});
    }
  }

  @override
  void dispose() {
    downloadService.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        title:
            Text("İndirme Kuyruğu ${queue.isEmpty ? "" : "(${queue.length})"}"),
        actions: [
          AnimatedSwitcher(
            duration: Duration(seconds: 1),
            child: getActionButton(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (downloadService.downloadQueue.isEmpty) ...[
            Expanded(
              child: Center(
                child: Text("Kuyrukta Hiç Müzik Yok"),
              ),
            )
          ],
          if (!downloadService.downloadQueue.isEmpty) ...[
            Expanded(
              child: ReorderableListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: downloadService.downloadQueue.length,
                itemBuilder: (c, i) {
                  MediaItem item = downloadService.downloadQueue[i];
                  bool isDownloading =
                      downloadService.downloadingItem?.id == item.id;
                  Widget child = buildMusicItem(
                    item,
                    downloadService.downloadQueue,
                    onPressed: () {
                      context.pushOpaque(PlayingScreen(
                        song: item,
                        queue: downloadService.downloadQueue,
                      ));
                    },
                    type: BuildMusicListType.Queue,
                    trailing: isDownloading
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: downloadService,
                                builder: (c, a) {
                                  return CircularProgressIndicator(
                                    color: Const.contrainsColor,
                                    value: downloadService.progress,
                                  );
                                },
                              ),
                              IconButton(
                                onPressed: () {
                                  downloadService.cancelDownload();
                                  setState(() {});
                                },
                                icon: Icon(Icons.close_rounded),
                              ),
                            ],
                          )
                        : PopupMenuButton<QueueActions>(
                            itemBuilder: (c) {
                              return [
                                if (i != 0)
                                  PopupMenuItem(
                                    value: QueueActions.Up,
                                    child: Row(
                                      children: [
                                        Icon(Icons
                                            .keyboard_double_arrow_up_rounded),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text("En Üste Taşı")
                                      ],
                                    ),
                                  ),
                                if (i !=
                                    downloadService.downloadQueue.length - 1)
                                  PopupMenuItem(
                                    value: QueueActions.Down,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons
                                              .keyboard_double_arrow_down_rounded,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text("En Alta Taşı")
                                      ],
                                    ),
                                  ),
                                if (!isDownloading)
                                  PopupMenuItem(
                                    value: QueueActions.Delete,
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline_rounded),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text("Kuyruktan Sil")
                                      ],
                                    ),
                                  ),
                                PopupMenuItem(
                                  value: QueueActions.Download,
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
                              ];
                            },
                            onSelected: (a) {
                              switch (a) {
                                case QueueActions.Up:
                                  MediaItem item =
                                      downloadService.downloadQueue.removeAt(i);
                                  downloadService.downloadQueue.insert(0, item);
                                  setState(() {});
                                  break;
                                case QueueActions.Down:
                                  MediaItem item =
                                      downloadService.downloadQueue.removeAt(i);
                                  downloadService.downloadQueue.add(item);
                                  setState(() {});
                                  break;
                                case QueueActions.Delete:
                                  downloadService.downloadQueue.removeAt(i);
                                  setState(() {});
                                  break;
                                case QueueActions.Download:
                                  if (!downloadService.isPreparing) {
                                    if (downloadService.downloadingItem !=
                                        null) {
                                      showDialog(
                                        context: context,
                                        builder: (c) {
                                          return AlertDialog(
                                            title: Text("Ne yapmak istersin?"),
                                            content: Text(
                                                "Hali hazırda indirilen bir müzik var, indirilen müziği iptal edip seçili müziği indirmek ister misin?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Hayır"),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  downloadService
                                                      .cancelDownload();
                                                  downloadService
                                                      .prepareDownload(
                                                          context, item);
                                                },
                                                child: Text("Evet"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else {
                                      downloadService.prepareDownload(
                                          context, item);
                                    }
                                  } else {
                                    showMessage(
                                      message:
                                          "Hali hazırda indirmeye hazırlanılan bir indirme var",
                                    );
                                  }
                                  setState(() {});
                                  break;
                                default:
                              }
                            },
                          ),
                  );

                  child = Container(
                    key: ValueKey(item),
                    child: child,
                    color: isDownloading
                        ? Const.contrainsColor.withOpacity(0.1)
                        : null,
                  );

                  if (!isDownloading) {
                    child = MyDismissible(
                      onDismissed: (l) {
                        downloadService.removeQueue(item);
                        queue.removeWhere((element) => element.id == item.id);
                        setState(() {});
                      },
                      key: ValueKey(item),
                      child: child,
                    );
                  }
                  return child;
                },
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) {
                    newIndex--;
                  }

                  var temp = downloadService.downloadQueue.removeAt(oldIndex);
                  downloadService.downloadQueue.insert(newIndex, temp);
                  queue = downloadService.downloadQueue;
                },
              ),
            ),
          ],
          MiniPlayer(),
        ],
      ),
    );
  }

  Widget getActionButton() {
    if (queue.isEmpty) {
      return SizedBox();
    } else {
      return IconButton(
        onPressed: () {
          downloadService.removeAllQueue(queue, showMsg: true);
        },
        icon: Icon(Icons.delete_sweep_rounded),
      );
    }
  }
}

enum QueueActions { Up, Down, Delete, Download }
