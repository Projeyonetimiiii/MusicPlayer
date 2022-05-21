import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
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

class _QueuePageState extends State<QueuePage> {
  List<MediaItem> queue = [];

  @override
  void initState() {
    queue = widget.queue.copyList;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant QueuePage oldWidget) {
    if (oldWidget.queue != widget.queue) {
      setState(() {
        queue = widget.queue.copyList;
      });
    }
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
                          color: Colors.white12,
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
                      if (playingSong != null) {
                        handler.updateMediaItemIndex(playingSong);
                      }
                      setState(() {});
                    },
                    physics: BouncingScrollPhysics(),
                    itemCount: queue.length,
                    itemBuilder: (BuildContext context, int index) {
                      MediaItem song = queue[index];
                      return ListTile(
                        key: Key(song.id.toString()),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        onTap: () {
                          if (widget.changeItem != null) {
                            widget.changeItem!(song);
                          }
                        },
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 100,
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: song.getImageWidget,
                            ),
                          ),
                        ),
                        trailing: playingSong?.id == song.id
                            ? Icon(
                                Icons.bar_chart_rounded,
                                color: Theme.of(context).colorScheme.secondary,
                              )
                            : Text(
                                Const.getDurationString(
                                    song.duration ?? Duration.zero),
                              ),
                        title: Text(
                          song.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14),
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
