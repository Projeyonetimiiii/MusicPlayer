import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class QueuePage extends StatefulWidget {
  final SongModel playingSong;
  final List<SongModel> queue;
  const QueuePage({
    Key? key,
    required this.playingSong,
    required this.queue,
  }) : super(key: key);

  @override
  _QueuePageState createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
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
                onReorder: (oldIndex, newIndex) async {},
                physics: BouncingScrollPhysics(),
                itemCount: widget.queue.length,
                itemBuilder: (BuildContext context, int index) {
                  SongModel song = widget.queue[index];
                  return ListTile(
                    key: Key(song.id.toString()),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    onTap: () {},
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 100,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: FutureBuilder<Uint8List?>(
                            future: OnAudioQuery.platform
                                .queryArtwork(song.id, ArtworkType.AUDIO),
                            builder: (c, snap) {
                              if (!snap.hasData) {
                                return Icon(Icons.hide_image_rounded);
                              } else {
                                return Image.memory(
                                  snap.data!,
                                  fit: BoxFit.cover,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    trailing: this.widget.playingSong.id == song.id
                        ? Icon(
                            Icons.bar_chart_rounded,
                            color: Theme.of(context).colorScheme.secondary,
                          )
                        : Text(
                            Duration(milliseconds: song.duration ?? 0)
                                .toString()
                                .split(".")
                                .first,
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
        ),
      ),
    );
  }
}
