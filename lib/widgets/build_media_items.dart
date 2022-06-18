import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/playing_screen/playing_screen.dart';

class BuildMediaItems extends StatelessWidget {
  final List<MediaItem> items;
  final bool scrollable;
  final EdgeInsets? padding;
  const BuildMediaItems({
    Key? key,
    required this.items,
    this.padding,
    this.scrollable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.artist.toString(),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            Const.getDurationString(item.duration!),
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
      onTap: () async {
        context.pushOpaque(
          PlayingScreen(
            queue: items,
            song: item,
          ),
        );
      },
    );
  }
}
