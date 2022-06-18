import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/models/genre.dart';
import 'package:onlinemusic/models/youtube_genre.dart';
import 'package:onlinemusic/models/youtube_playlist.dart';
import 'package:onlinemusic/services/audios_bloc.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/playing_screen/playing_screen.dart';
import 'package:onlinemusic/views/playlist_screen/widgets/my_gridview.dart';
import 'package:onlinemusic/views/playlist_screen/yt_playlist_screen.dart';
import 'package:onlinemusic/widgets/custom_back_button.dart';
import 'package:onlinemusic/widgets/mini_player.dart';

class PlaylistScreen extends StatefulWidget {
  final bool isYoutube;
  final YoutubeGenre? youtubeGenre;
  final Genre? genre;
  const PlaylistScreen.YoutubeGenre({Key? key, required this.youtubeGenre})
      : genre = null,
        isYoutube = true,
        super(key: key);
  const PlaylistScreen.Genre({Key? key, this.genre})
      : youtubeGenre = null,
        isYoutube = false,
        super(key: key);

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  String get title {
    return (widget.isYoutube
            ? widget.youtubeGenre?.title
            : widget.genre?.name) ??
        "Title";
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
      ),
    );
  }

  Widget getBody() {
    if (widget.isYoutube) {
      return MyGridView(
        children: widget.youtubeGenre!.playlists!.map((e) {
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
      List<MediaItem> items = AudiosBloc()
          .getAudiosFromGenreId(widget.genre!.id)
          .map((e) => e.toMediaItem)
          .toList();

      return MyGridView(
        children: items.map((e) {
          return buildItem(
            e.title,
            () {
              mediaItemOnTap(items, e);
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

  void mediaItemOnTap(List<MediaItem> queue, MediaItem song) {
    context.pushOpaque(
      PlayingScreen(
        song: song,
        queue: queue,
      ),
    );
  }

  Padding buildItem(
    String title,
    VoidCallback onTap, {
    Widget? imageWidget,
    String image = "",
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
