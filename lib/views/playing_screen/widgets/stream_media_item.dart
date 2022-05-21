import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/main.dart';

typedef MediaItemBuilder = Widget Function(MediaItem?);

class StreamMediaItem extends StatefulWidget {
  final MediaItemBuilder builder;
  StreamMediaItem({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  State<StreamMediaItem> createState() => _StreamMediaItemState();
}

class _StreamMediaItemState extends State<StreamMediaItem> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MediaItem?>(
      stream: handler.mediaItem,
      builder: (context, snapshot) {
        MediaItem? mediaItem = snapshot.data;
        return widget.builder(mediaItem);
      },
    );
  }
}
