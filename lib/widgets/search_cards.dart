import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/playing_screen/playing_screen.dart';

class BuildMediaItems extends StatelessWidget {
  final List<MediaItem> items;
  final bool scrollable;
  const BuildMediaItems({
    Key? key,
    required this.items,
    this.scrollable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: !scrollable,
      physics:
          scrollable ? BouncingScrollPhysics() : NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (c, i) {
        return buildMusicItem(items[i], items, context);
      },
    );
  }

  Widget buildMusicItem(
      MediaItem item, List<MediaItem> queue, BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
      onTap: () {
        context.pushOpaque(PlayingScreen(
          queue: queue,
          song: item,
        ));
      },
      leading: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 10,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 100,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: item.getImageWidget,
            ),
          ),
        ),
      ),
      trailing: Text(
        Const.getDurationString(item.duration ?? Duration.zero),
      ),
      subtitle: Text(item.artist ?? "Artist"),
      title: Text(
        item.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 14),
      ),
    );
  }
}
