import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/widgets/custom_back_button.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String url;
  final bool isLocal;
  const VideoPlayerScreen({
    Key? key,
    required this.url,
    required this.isLocal,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool lastPlayingStatusIsPlaying = false;

  @override
  void initState() {
    try {
      lastPlayingStatusIsPlaying = handler.isPlaying;
      handler.pause();
    } on Exception catch (_) {}
    super.initState();
  }

  @override
  void dispose() {
    if (lastPlayingStatusIsPlaying) {
      try {
        handler.play();
      } on Exception catch (_) {}
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CustomBackButton(
          color: Const.kBackground,
        ),
      ),
      body: getBody(),
    );
  }

  Widget getBody() {
    if (widget.isLocal) {
      return BetterPlayer.file(widget.url);
    } else {
      return BetterPlayer.network(widget.url);
    }
  }
}
