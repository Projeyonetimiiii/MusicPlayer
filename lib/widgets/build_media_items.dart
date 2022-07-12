import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/util/enums.dart';
import 'package:onlinemusic/util/mixins.dart';

typedef Builder = Widget Function(Widget, MediaItem);

class BuildMediaItems extends StatelessWidget with BuildMediaItemMixin {
  final List<MediaItem> items;
  final bool scrollable;
  final EdgeInsets? padding;
  final BuildMusicListType? type;
  final Builder? builder;
  const BuildMediaItems({
    Key? key,
    required this.items,
    this.padding,
    this.type,
    this.scrollable = true,
    this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text("Burada hiçbirşey yok"),
      );
    }

    return ListView.builder(
      padding: padding,
      shrinkWrap: !scrollable,
      physics:
          scrollable ? BouncingScrollPhysics() : NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (c, i) {
        Widget child = buildMusicItem(items[i], items,
            type: type ?? BuildMusicListType.None);
        if (builder != null) {
          return builder!(child, items[i]);
        }
        return child;
      },
    );
  }
}
