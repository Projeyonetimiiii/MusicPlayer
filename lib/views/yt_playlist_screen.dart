import 'dart:convert';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/models/youtube_playlist.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/converter.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/playing_screen/playing_screen.dart';
import 'package:onlinemusic/views/video_player_page.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YtPlaylistScreen extends StatefulWidget {
  final YoutubePlaylist playlist;
  YtPlaylistScreen({Key? key, required this.playlist}) : super(key: key);

  @override
  _YtPlaylistScreenState createState() => _YtPlaylistScreenState();
}

class _YtPlaylistScreenState extends State<YtPlaylistScreen> {
  YoutubePlaylist get playlist => widget.playlist;
  late YoutubeExplode _yt;
  List<MediaItem> searchedList = [];

  bool fetched = false;

  @override
  void initState() {
    _yt = YoutubeExplode();
    if (playlist.isPlaylist) searchedList = getInitialVideos();
    fetched = searchedList.isNotEmpty;
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
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
    return !playlist.isPlaylist
        ? FutureBuilder<String>(
            future: getVideoUrl(playlist.firstItemId!.toString()),
            builder: (c, s) {
              if (s.hasData) {
                return VideoPlayerPage(url: s.data!, isLocal: false);
              } else {
                return CircularProgressIndicator(
                  color: Colors.white,
                );
              }
            },
          )
        : Scaffold(
            resizeToAvoidBottomInset: true,
            body: Column(
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
                        backgroundColor: Colors.grey.shade200,
                        iconTheme: IconThemeData(
                          color: Const.kBackground,
                        ),
                        leading: Center(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Const.kBackground,
                              ),
                            ),
                          ),
                        ),
                        expandedHeight:
                            MediaQuery.of(context).size.height * 0.4,
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
                                color: Const.kBackground,
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
                                  Rect.fromLTWH(0, 0, rect.width, rect.height));
                            },
                            child: CachedNetworkImage(
                              imageUrl: playlist.getLowQualityImageUrl,
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
                                        child: entry.getImageWidget,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    entry.title.toString(),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            entry.artist.toString(),
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        Const.getDurationString(
                                            entry.duration!),
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () async {
                                    context.pushOpaque(
                                      PlayingScreen(
                                        queue: searchedList,
                                        song: entry,
                                      ),
                                    );
                                  },
                                );
                              },
                            ).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}

Future<String> getVideoUrl(String id) async {
  StreamManifest url =
      await YoutubeExplode().videos.streamsClient.getManifest(id);
  return url.muxed.bestQuality.url.toString();
}
