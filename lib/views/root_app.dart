import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/converter.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/chat/chats_screen.dart';
import 'package:onlinemusic/views/favorite_page.dart';
import 'package:onlinemusic/views/home_page.dart';
import 'package:onlinemusic/views/library_page.dart';
import 'package:onlinemusic/views/playing_screen/playing_screen.dart';
import 'package:onlinemusic/views/share_song_page.dart';
import 'package:onlinemusic/widgets/mini_player.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class RootApp extends StatefulWidget {
  RootApp({Key? key}) : super(key: key);

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  PageController _pageController = PageController();
  final _bottomPageNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    AudioService.notificationClicked.listen((clicked) {
      if (clicked) {
        BuildContext? navigatorContext = MyApp.navigatorKey.currentContext;
        if (navigatorContext != null) {
          if (!PlayingScreen.isRunning) {
            navigatorContext.pushOpaque(PlayingScreen());
          }
        }
      }
    });
    updateWithLastDatas();
    super.initState();
  }

  void updateWithLastDatas() {
    int? lastRepeatMode = cacheBox!.get("lastRepeatMode");
    int? lastShuffleMode = cacheBox!.get("lastShuffleMode");
    List? lastQueue = cacheBox!.get("lastQueue");
    String? lastMediaItem = cacheBox!.get("lastMediaItem");
    if (lastRepeatMode != null) {
      AudioServiceRepeatMode repeatMode =
          AudioServiceRepeatMode.values[lastRepeatMode];
      handler.setRepeatMode(repeatMode);
    }
    if (lastShuffleMode != null) {
      AudioServiceShuffleMode shuffleMode =
          AudioServiceShuffleMode.values[lastShuffleMode];
      handler.setShuffleMode(shuffleMode);
    }
    if (lastQueue != null) {
      List<MediaItem> queue =
          lastQueue.map((e) => MediaItemConverter.jsonToMediaItem(e)).toList();
      handler.updateQueue(queue);
    }
    if (lastMediaItem != null) {
      MediaItem item = MediaItemConverter.jsonToMediaItem(lastMediaItem);
      handler.playMediaItem(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: (s) {
          _bottomPageNotifier.value = s;
        },
        children: [
          YoutubeHomePage(
            key: PageStorageKey("home"),
          ),
          FavoritePage(
            key: PageStorageKey("favorite"),
          ),
          ChatsScreen(
            key: PageStorageKey("chat"),
          ),
          LibraryPage(
            key: PageStorageKey("library"),
          ),
        ],
      ),
      floatingActionButton: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5,
            sigmaY: 5,
          ),
          child: FloatingActionButton.extended(
            extendedIconLabelSpacing: 0,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
                side: BorderSide(
                  color: Const.kBackground,
                  width: 2,
                )),
            backgroundColor: Const.kBackground.withOpacity(0.5),
            label: Text(
              "Yayınla ",
              style: TextStyle(
                  color: Const.kWhite,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                  fontSize: 16),
            ),
            onPressed: () {
              context.push(ShareSongPage());
            },
            icon: Icon(
              Icons.add,
              color: Const.kWhite,
            ),
          ),
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _bottomPageNotifier,
        builder: (context, v, snap) {
          return StreamBuilder<bool>(
            stream: handler.mediaItem.map((event) => event != null).distinct(),
            builder: (context, isThereItem) {
              return StreamBuilder<PlaybackState?>(
                stream: handler.playbackState,
                builder: (context, snapshot) {
                  final playbackState = snapshot.data;
                  final processingState = playbackState?.processingState;
                  bool isIdle = processingState == AudioProcessingState.idle;
                  bool showPlayer = (isThereItem.data == true);

                  Widget bottomBar = AnimatedContainer(
                    duration: Duration(milliseconds: 350),
                    margin: EdgeInsets.only(
                      left: 8,
                      right: 8,
                      bottom: 8,
                      top: showPlayer && !isIdle ? 58 : 0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(27),
                      boxShadow: [
                        BoxShadow(
                          color: Const.kBackground.withOpacity(0.4),
                          blurRadius: 2,
                          offset: Offset(0, 0),
                        ),
                      ],
                      color: Colors.white,
                    ),
                    child: SalomonBottomBar(
                      itemPadding:
                          EdgeInsets.symmetric(vertical: 7, horizontal: 20),
                      currentIndex: v,
                      onTap: (i) {
                        _pageController.jumpToPage(i);
                      },
                      items: [
                        SalomonBottomBarItem(
                          selectedColor: Const.kBackground,
                          unselectedColor: Const.kBackground.withOpacity(0.4),
                          title: Text("Ana Sayfa"),
                          icon: Icon(Icons.audiotrack_rounded),
                        ),
                        SalomonBottomBarItem(
                          selectedColor: Const.kBackground,
                          unselectedColor: Const.kBackground.withOpacity(0.4),
                          title: Text("Favoriler"),
                          icon: Icon(Icons.favorite),
                        ),
                        SalomonBottomBarItem(
                          selectedColor: Const.kBackground,
                          unselectedColor: Const.kBackground.withOpacity(0.4),
                          title: Text("Mesajlar"),
                          icon: Icon(Icons.message_rounded),
                        ),
                        SalomonBottomBarItem(
                          selectedColor: Const.kBackground,
                          unselectedColor: Const.kBackground.withOpacity(0.4),
                          title: Text("Cihaz"),
                          icon: Icon(Icons.library_music_rounded),
                        ),
                      ],
                    ),
                  );

                  if (showPlayer) {
                    bottomBar = Stack(
                      children: [
                        if (!isIdle)
                          MiniPlayer(
                            style: MiniPlayer.sStyle.copyWith(
                              boxShadow: BoxShadow(
                                blurRadius: 5,
                                color: Colors.black54,
                              ),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              margin: EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                            isBottomBar: true,
                          ),
                        if (isIdle)
                          TweenAnimationBuilder<double>(
                            tween: Tween(
                              begin: 87,
                              end: 0,
                            ),
                            duration: Duration(milliseconds: 350),
                            builder: (c, v, i) {
                              return Positioned(
                                right: 0,
                                left: 0,
                                bottom: 29,
                                child: Container(
                                  height: v,
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  width: double.maxFinite,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    color: Colors.grey.shade200,
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 5,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        bottomBar,
                      ],
                    );
                  }
                  return bottomBar;
                },
              );
            },
          );
        },
      ),
    );
  }
}
