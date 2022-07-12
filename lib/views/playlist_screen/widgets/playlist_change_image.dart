import 'package:flutter/material.dart';
import 'package:onlinemusic/models/my_playlist.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/playlist_screen/widgets/change_image_controller.dart';

class PlaylistChangeImage extends StatefulWidget {
  final MyPlaylist playlist;
  final ChangeImageController controller;
  PlaylistChangeImage({
    Key? key,
    required this.playlist,
    required this.controller,
  }) : super(key: key);

  @override
  State<PlaylistChangeImage> createState() => _PlaylistChangeImageState();
}

class _PlaylistChangeImageState extends State<PlaylistChangeImage> {
  int index = 0;
  late Widget image;

  @override
  void initState() {
    image = widget.playlist.songs.first.getImageWidget;
    widget.controller.addListener(listener);
    super.initState();
  }

  void listener() {
    if (index < widget.playlist.songs.length - 2) {
      index++;
    } else {
      index = 0;
    }
    if (mounted) {
      setState(() {
        image = widget.playlist.songs[index].getImageWidget;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(seconds: 1),
      child: Stack(
        key: ValueKey(index),
        children: [
          Positioned.fill(child: image),
        ],
      ),
    );
  }
}
