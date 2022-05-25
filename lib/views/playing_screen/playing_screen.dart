import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/providers/data.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/playing_screen/widgets/seekbar.dart';
import 'package:onlinemusic/views/playing_screen/widgets/stream_media_item.dart';
import 'package:onlinemusic/views/queue_screen.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../video_player_page.dart';

class PlayingScreen extends StatefulWidget {
  final MediaItem? song;
  final List<MediaItem>? queue;
  PlayingScreen({
    Key? key,
    this.song,
    this.queue,
  }) : super(key: key);

  static bool isRunning = false;

  @override
  _PlayingScreenState createState() => _PlayingScreenState();
}

class _PlayingScreenState extends State<PlayingScreen>
    with TickerProviderStateMixin {
  late bool isFavorite;
  late PageController pageController;
  final YoutubeExplode yt = YoutubeExplode();

  MediaItem? get song => widget.song;
  MyData get myData => context.myData;

  @override
  void initState() {
    super.initState();
    PlayingScreen.isRunning = true;
    pageController = PageController();
    setMediaItem(updateQueue: true);
  }

  @override
  void dispose() {
    PlayingScreen.isRunning = false;
    super.dispose();
  }

  Future<void> updateQueue() async {
    if (widget.queue != null) {
      await handler.updateQueue(widget.queue!);
      await handler.setShuffleMode(AudioServiceShuffleMode.none);
      await handler.setRepeatMode(AudioServiceRepeatMode.none);
    }
  }

  void setMediaItem({MediaItem? mediaItem, bool updateQueue = false}) async {
    if (updateQueue) {
      await this.updateQueue();
    }
    MediaItem? newItem = mediaItem ?? song;
    if (newItem != null) {
      await handler.playMediaItem(newItem);
      await handler.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: playingScreenBody(context),
    );
  }

  Stack playingScreenBody(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: PageView(
            controller: pageController,
            children: [
              ListView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top,
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          physics: NeverScrollableScrollPhysics(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  children: [
                                    buildTopActions(),
                                    buildImageWidget(),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    buildTitleWidget(),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: buildSliderWidget(),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  children: [
                                    buildActionsWidget(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              StreamBuilder<List<MediaItem>>(
                stream: handler.queue,
                initialData: handler.queue.value,
                builder: (context, snapshot) {
                  return QueuePage(
                    queue: snapshot.data ?? [],
                    changeItem: (newSong) {
                      setMediaItem(mediaItem: newSong);
                      pageController.animateToPage(
                        0,
                        duration: Duration(milliseconds: 350),
                        curve: Curves.linear,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Padding buildTopActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.keyboard_arrow_down_rounded, size: 40),
          ),
          StreamMediaItem(
            builder: (song) {
              if (song?.isOnline == false) {
                return SizedBox();
              }
              return Row(
                children: [
                  if (song?.type.isVideo ?? true)
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        StreamManifest url =
                            await yt.videos.streamsClient.getManifest(song!.id);
                        context.push(
                          VideoPlayerPage(
                              isLocal: true,
                              url: url.muxed.bestQuality.url.toString()),
                        );
                      },
                      icon: Icon(Icons.youtube_searched_for_rounded, size: 30),
                    ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {},
                    icon: Icon(Icons.person_search_rounded, size: 30),
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Padding buildImageWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: 1,
        child: Card(
          elevation: 4,
          child: StreamMediaItem(
            builder: (song) {
              if (song == null) return SizedBox();
              return GestureDetector(
                onDoubleTap: () {
                  myData.addFavoriteSong(song);
                },
                child: song.getImageWidget,
              );
            },
          ),
        ),
      ),
    );
  }

  StreamMediaItem buildActionsWidget() {
    return StreamMediaItem(
      builder: (song) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StreamBuilder<bool>(
              stream: handler.playbackState
                  .map((event) =>
                      event.shuffleMode == AudioServiceShuffleMode.all)
                  .distinct(),
              initialData: false,
              builder: (context, snapshot) {
                bool isShuffleMode = snapshot.data!;
                return IconButton(
                  onPressed: () {
                    handler.setShuffleMode(isShuffleMode
                        ? AudioServiceShuffleMode.none
                        : AudioServiceShuffleMode.all);
                    setState(() {});
                  },
                  icon: Icon(Icons.shuffle),
                  iconSize: 20,
                  color: isShuffleMode ? Colors.black : Colors.black54,
                );
              },
            ),
            Row(
              children: [
                IconButton(
                  onPressed: !handler.hasPrev
                      ? null
                      : () async {
                          await handler.skipToPrevious();
                          handler.play();
                        },
                  icon: Icon(Icons.skip_previous),
                ),
                SizedBox(
                  width: 6,
                ),
                StreamBuilder<bool>(
                  stream: handler.playingStream,
                  builder: (context, snapshot) {
                    bool isPlaying = snapshot.data ?? false;
                    return IconButton(
                      onPressed: () async {
                        if (isPlaying) {
                          handler.pause();
                        } else {
                          handler.play();
                        }
                      },
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    );
                  },
                ),
                SizedBox(
                  width: 6,
                ),
                IconButton(
                  onPressed: !handler.hasNext
                      ? null
                      : () async {
                          await handler.skipToNext();
                          handler.play();
                        },
                  icon: Icon(Icons.skip_next),
                ),
              ],
            ),
            StreamBuilder<AudioServiceRepeatMode>(
              stream: handler.playbackState
                  .map((event) => event.repeatMode)
                  .distinct(),
              builder: (context, snapshot) {
                return IconButton(
                  onPressed: () {
                    myData.setRepeatMode();
                    setState(() {});
                  },
                  icon: myData.getRepeatModeIcon(
                      snapshot.data ?? AudioServiceRepeatMode.none),
                  iconSize: 20,
                );
              },
            ),
          ],
        );
      },
    );
  }

  SizedBox buildSliderWidget() {
    return SizedBox(
      height: 70,
      width: double.maxFinite,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StreamBuilder<Duration>(
                      stream: AudioService.position,
                      builder: (context, snapshot) {
                        return Text(
                          Const.getDurationString(
                              handler.playbackState.value.position),
                        );
                      }),
                  StreamMediaItem(
                    builder: (song) {
                      return Text(
                        Const.getDurationString(
                          song?.duration ?? Duration.zero,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: StreamMediaItem(
              builder: (song) {
                return StreamBuilder<Duration>(
                  stream: AudioService.position,
                  builder: (context, snapshot) {
                    Duration position = handler.playbackState.value.position;

                    Duration bufferedPosition =
                        handler.playbackState.value.bufferedPosition;
                    return SeekBar(
                      duration: song?.duration ?? Duration.zero,
                      bufferedPosition: bufferedPosition,
                      position: position,
                      onChangeEnd: (position) {
                        handler.seek(position);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Padding buildTitleWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: StreamMediaItem(
        builder: (song) {
          return SizedBox(
            width: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: "title",
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      song?.title ?? "Title",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Hero(
                  tag: "artist",
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      song?.artist ?? "Artist",
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
