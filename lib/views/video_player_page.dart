import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class VideoPlayerPage extends StatefulWidget {
  final String url;
  final bool isLocal;
  const VideoPlayerPage({
    Key? key,
    required this.url,
    required this.isLocal,
  }) : super(key: key);

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.isLocal) {
      return BetterPlayer.file(widget.url);
    } else {
      return BetterPlayer.network(widget.url);
    }
  }
}
