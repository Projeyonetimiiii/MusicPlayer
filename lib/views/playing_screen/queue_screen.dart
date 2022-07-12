import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/enums.dart';
import 'package:onlinemusic/util/mixins.dart';
import 'package:onlinemusic/views/playing_screen/widgets/stream_media_item.dart';

class QueuePage extends StatefulWidget {
  final List<MediaItem> queue;
  final ValueChanged<MediaItem>? changeItem;
  const QueuePage({
    Key? key,
    required this.queue,
    this.changeItem,
  }) : super(key: key);

  @override
  _QueuePageState createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> with BuildMediaItemMixin {
  List<MediaItem> queue = [];

  @override
  void initState() {
    queue = widget.queue.toList();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant QueuePage oldWidget) {
    setState(() {
      queue = widget.queue.toList();
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: StreamMediaItem(
          builder: (playingSong) {
            return Stack(
              children: [
                SafeArea(
                  child: ReorderableListView.builder(
                    proxyDecorator: (c, i, a) {
                      return Material(
                        color: Colors.transparent,
                        child: Container(
                          color: Const.contrainsColor.withOpacity(0.1),
                          child: c,
                        ),
                      );
                    },
                    onReorder: (oldIndex, newIndex) async {
                      if (oldIndex < newIndex) {
                        newIndex--;
                      }
                      MediaItem temp = widget.queue[oldIndex];
                      queue.removeAt(oldIndex);
                      queue.insert(newIndex, temp);
                      await handler.updateQueue(queue);
                      print("reordered");
                      if (playingSong != null) {
                        print("index bulunuyor");
                        handler.updateMediaItemIndex(playingSong);
                      }
                      setState(() {});
                    },
                    physics: BouncingScrollPhysics(),
                    itemCount: queue.length,
                    itemBuilder: (BuildContext context, int index) {
                      MediaItem song = queue[index];
                      return Container(
                        key: Key(song.id),
                        color: song.id == playingSong?.id
                            ? Const.contrainsColor.withOpacity(0.1)
                            : Colors.transparent,
                        child: buildMusicItem(
                          song,
                          queue,
                          onPressed: () {
                            widget.changeItem?.call(song);
                          },
                          type: BuildMusicListType.Queue,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
