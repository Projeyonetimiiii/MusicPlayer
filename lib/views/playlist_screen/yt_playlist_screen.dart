import 'dart:convert';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/models/youtube_playlist.dart';
import 'package:onlinemusic/services/download_service.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/converter.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/util/mixins.dart';
import 'package:onlinemusic/views/video_player_screen.dart';
import 'package:onlinemusic/widgets/mini_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YtPlaylistScreen extends StatefulWidget {
  final YoutubePlaylist playlist;
  YtPlaylistScreen({Key? key, required this.playlist}) : super(key: key);

  @override
  _YtPlaylistScreenState createState() => _YtPlaylistScreenState();
}

class _YtPlaylistScreenState extends State<YtPlaylistScreen>
    with BuildMediaItemMixin {
  YoutubePlaylist get playlist => widget.playlist;
  late YoutubeExplode _yt;
  List<MediaItem> searchedList = [];

  bool fetched = false;

  @override
  void initState() {
    _yt = YoutubeExplode();
    if (playlist.isPlaylist) searchedList = getInitialVideos();
    fetched = searchedList.isNotEmpty;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (playlist.isPlaylist) {
        getVideos();
      }
    });
    super.initState();
  }

  getInitialVideos() {
    return (songsBox!.get(playlist.playlistId!, defaultValue: []) as List)
        .map((e) => MediaItemConverter.mapToMediaItem(jsonDecode(e)))
        .toList();
  }

  getVideos() async {
    List<Video> videosList =
        await _yt.playlists.getVideos(playlist.playlistId).toList();
    this.searchedList = videosList.map((e) => e.toMediaItem).toList();
    saveHive(searchedList);
    fetched = true;
    if (mounted) setState(() {});
  }

  void saveHive(List<MediaItem> searchedList) {
    songsBox!.put(playlist.playlistId!,
        searchedList.map((e) => jsonEncode(e.toMap)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: getBody(),
    );
  }

  Widget getBody() {
    if (!playlist.isPlaylist) {
      return FutureBuilder<String>(
        future: getVideoUrl(playlist.firstItemId!.toString()),
        builder: (c, s) {
          if (s.hasData) {
            return VideoPlayerScreen(url: s.data!, isLocal: false);
          } else {
            return Center(
              child: CircularProgressIndicator(
                color: Const.kBackground,
              ),
            );
          }
        },
      );
    } else {
      return Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  elevation: 0,
                  stretch: true,
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                  backgroundColor: Const.themeColor,
                  iconTheme: IconThemeData(
                    color: Const.contrainsColor,
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Center(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(5),
                          onTap: () {
                            downloadService.addAllQueue(
                              searchedList,
                              context,
                              isTest: true,
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Const.themeColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Icon(
                              Icons.download_rounded,
                              color: Const.contrainsColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  leading: Center(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Const.themeColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Const.contrainsColor,
                        ),
                      ),
                    ),
                  ),
                  expandedHeight: MediaQuery.of(context).size.height * 0.4,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: EdgeInsets.only(bottom: 19, left: 60),
                    title: Padding(
                      padding: const EdgeInsets.only(right: 50),
                      child: Text(
                        playlist.title ?? "",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 16,
                          color: Const.contrainsColor,
                        ),
                      ),
                    ),
                    background: ShaderMask(
                      blendMode: BlendMode.dstOut,
                      shaderCallback: (rect) {
                        return LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.white,
                          ],
                        ).createShader(
                          Rect.fromLTWH(0, 0, rect.width, rect.height),
                        );
                      },
                      child: CachedNetworkImage(
                        imageUrl: playlist.getStandartImage,
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
                if (!fetched)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Const.kBackground,
                        ),
                      ),
                    ),
                  ),
                if (fetched)
                  SliverList(
                    delegate: SliverChildListDelegate(
                      searchedList.map(
                        (MediaItem entry) {
                          return buildMusicItem(entry, searchedList);
                        },
                      ).toList(),
                    ),
                  ),
              ],
            ),
          ),
          MiniPlayer(
            style: MiniPlayer.sStyle.copyWith(
              boxShadow: BoxShadow(
                blurRadius: 4,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      );
    }
  }
}

Future<String> getVideoUrl(String id) async {
  StreamManifest url =
      await YoutubeExplode().videos.streamsClient.getManifest(id);
  return url.muxed.bestQuality.url.toString();
}
