import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:onlinemusic/views/queue_screen.dart';

class PlayingScreen extends StatefulWidget {
  final SongModel song;
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

  SongModel get song => widget.song;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: playingScreenBody(context, song),
    );
  }

  Stack playingScreenBody(BuildContext context, SongModel song) {
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
                                    buildImageWidget(context, song),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    buildTitleWidget(song),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: buildSliderWidget(song),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  children: [
                                    buildActionsWidget(),
                                  ],
                                ),
                              ),
                              SizedBox(),
                              SizedBox(),
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

  Padding buildImageWidget(BuildContext context, SongModel video) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: 1,
        child: FutureBuilder<Uint8List?>(
          future:
              OnAudioQuery.platform.queryArtwork(song.id, ArtworkType.AUDIO),
          builder: (c, snap) {
            if (!snap.hasData) {
              return Icon(Icons.hide_image_rounded);
            } else {
              return Image.memory(
                snap.data!,
                fit: BoxFit.cover,
              );
            }
          },
        ),
      ),
    );
  }

  Row buildActionsWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {},
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
            IconButton(
              onPressed: () async {},
              icon: Icon(Icons.play_arrow),
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
          onPressed: () {},
          icon: Icon(Icons.repeat),
          iconSize: 20,
        ),
      ],
    );
  }

  SizedBox buildSliderWidget(SongModel song) {
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
                  Text(
                    "0:00",
                  ),
                  Text(
                    Duration(milliseconds: song.duration ?? 0)
                        .toString()
                        .split(".")
                        .first,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 11,
            right: 0,
            left: 0,
            child: Slider(
              value: 0.5,
              min: 0,
              max: 1,
              onChanged: (double value) {},
            ),
          ),
          Positioned(
            bottom: -5,
            right: 6,
            child: IconButton(
              onPressed: () {},
              icon: Text(
                "1x",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding buildTitleWidget(SongModel video) {
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
                  video.title,
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
                  video.artist!,
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
