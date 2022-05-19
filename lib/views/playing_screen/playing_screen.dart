import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/providers/data.dart';
import 'package:onlinemusic/services/background_audio_handler.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/playing_screen/widgets/seekbar.dart';
import 'package:onlinemusic/views/queue_screen.dart';

class PlayingScreen extends StatefulWidget {
  final MediaItem song;
  PlayingScreen({
    Key? key,
    required this.song,
  }) : super(key: key);

  @override
  _PlayingScreenState createState() => _PlayingScreenState();
}

class _PlayingScreenState extends State<PlayingScreen>
    with TickerProviderStateMixin {
  late bool isFavorite;
  late PageController pageController;

  MediaItem get song => widget.song;
  BackgroundAudioHandler get handler => context.myData.handler;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    setUrl();
  }

  void setUrl() async {
    await handler.playMediaItem(song);
    await handler.play();
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
              QueuePage(
                playingSong: song,
                queue: [song],
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
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.person_search_rounded, size: 30),
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
          child: song.getImageWidget,
        ),
      ),
    );
  }

  Row buildActionsWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: null,
          icon: Icon(Icons.shuffle),
          iconSize: 20,
        ),
        Row(
          children: [
            IconButton(
              onPressed: () async {},
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
                      context.myData.handler.pause();
                    } else {
                      context.myData.handler.play();
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
              onPressed: () async {},
              icon: Icon(Icons.skip_next),
            ),
          ],
        ),
        IconButton(
          onPressed: null,
          icon: Icon(Icons.repeat),
          iconSize: 20,
        ),
      ],
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
                      stream: handler.positionStream,
                      initialData: Duration.zero,
                      builder: (context, snapshot) {
                        Duration position = snapshot.data!;
                        return Text(
                          Const.getDurationString(position),
                        );
                      }),
                  Text(
                    Const.getDurationString(song.duration ?? Duration.zero),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: StreamBuilder<PlaybackState>(
              stream: handler.playbackState,
              builder: (context, snapshot) {
                PlaybackState? state = snapshot.data;
                Duration position = state?.position ?? Duration.zero;
                Duration bufferedPosition =
                    state?.bufferedPosition ?? Duration.zero;
                return SeekBar(
                  duration: song.duration ?? Duration.zero,
                  bufferedPosition: bufferedPosition,
                  position: position,
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
      child: SizedBox(
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: "title",
              child: Material(
                color: Colors.transparent,
                child: Text(
                  song.title,
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
                  song.artist ?? "Sanatçı",
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
