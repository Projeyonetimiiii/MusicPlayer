import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/models/youtube_playlist.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/playing_screen/playing_screen.dart';
import 'package:onlinemusic/views/playlist_screen/widgets/my_gridview.dart';
import 'package:onlinemusic/views/playlist_screen/yt_playlist_screen.dart';
import 'package:onlinemusic/widgets/custom_back_button.dart';
import 'package:onlinemusic/widgets/mini_player.dart';

class PlaylistAllItemsScreen extends StatefulWidget {
  final String? title;
  final bool isPlaylist;
  final List<YoutubePlaylist>? playlists;
  final List<MediaItem>? songs;
  const PlaylistAllItemsScreen({
    Key? key,
    this.isPlaylist = true,
    required this.title,
    required this.playlists,
  })  : this.songs = null,
        super(key: key);

  const PlaylistAllItemsScreen.fromSongs({
    Key? key,
    this.isPlaylist = false,
    required this.title,
    required this.songs,
  })  : this.playlists = null,
        super(key: key);

  @override
  State<PlaylistAllItemsScreen> createState() => _PlaylistAllItemsScreenState();
}

class _PlaylistAllItemsScreenState extends State<PlaylistAllItemsScreen> {
  String get title {
    return widget.title ?? "Title";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: CustomBackButton(),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: getBody()),
          MiniPlayer(),
        ],
      ),
    );
  }

  Widget getBody() {
    if (widget.isPlaylist) {
      return MyGridView(
        children: widget.playlists!.map((e) {
          return buildItem(
            e.title ?? title,
            () {
              playlistOnTap(e);
            },
            image: e.getStandartImage,
          );
        }).toList(),
        axisCount: 3,
      );
    } else {
      return MyGridView(
        children: widget.songs!.map((e) {
          return buildItem(
            e.title,
            () {
              context.pushOpaque(PlayingScreen(
                song: e,
                queue: widget.songs,
              ));
            },
            imageWidget: e.getImageWidget,
          );
        }).toList(),
        axisCount: 3,
      );
    }
  }

  void playlistOnTap(YoutubePlaylist playlist) {
    context.push(
      YtPlaylistScreen(playlist: playlist),
    );
  }

  Padding buildItem(
    String title,
    VoidCallback onTap, {
    String image = "",
    Widget? imageWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child: Card(
          margin: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        child: imageWidget ??
                            CachedNetworkImage(
                              imageUrl: image,
                              fit: BoxFit.cover,
                              placeholder: (c, i) {
                                return Image.asset(
                                  "assets/images/default_song_image.png",
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(8),
                  ),
                  color: Colors.white,
                ),
                child: Center(
                  child: Text(
                    title,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
