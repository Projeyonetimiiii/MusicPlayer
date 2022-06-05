import 'package:audio_service/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/models/usermodel.dart';
import 'package:onlinemusic/providers/data.dart';
import 'package:onlinemusic/services/auth.dart';
import 'package:onlinemusic/services/listening_song_service.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/message_screen/message_screen.dart';
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
        Positioned(
          top: 0,
          bottom: 0,
          left: 15.5,
          child: VerticalDivider(
            thickness: 1,
            width: 1,
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: 15.5,
          child: VerticalDivider(
            thickness: 1,
            width: 1,
          ),
        ),
        Positioned.fill(
          child: PageView(
            controller: pageController,
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildTopActions(),
                              buildImageWidget(),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildTitleWidget(),
                              buildSliderWidget(),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: buildActionsWidget(),
                        ),
                        SizedBox(),
                      ],
                    ),
                  ),
                ),
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

  Widget buildTopActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.loose(Size.square(30)),
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.keyboard_arrow_down_rounded, size: 30),
          ),
          Spacer(),
          StreamMediaItem(
            builder: (song) {
              return Row(
                children: [
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: AuthService().getUserStreamFromId(
                        FirebaseAuth.instance.currentUser!.uid),
                    builder: (c, snap) {
                      if (!snap.hasData) {
                        return SizedBox();
                      }

                      UserModel user = UserModel.fromMap(snap.data!.data()!);
                      if (user.connectedUserId != null) {
                        return StreamBuilder<
                            DocumentSnapshot<Map<String, dynamic>>>(
                          stream: AuthService()
                              .getUserStreamFromId(user.connectedUserId!),
                          builder: (c, snap) {
                            if (!snap.hasData) {
                              return SizedBox();
                            }

                            UserModel user =
                                UserModel.fromMap(snap.data!.data()!);
                            return InkWell(
                              onTap: () {
                                context.push(MessageScreen());
                              },
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(user.image!),
                                radius: 14,
                              ),
                            );
                          },
                        );
                      } else {
                        return SizedBox();
                      }
                    },
                  ),
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
                  if (song?.isOnline == true)
                    PopupMenuButton<MatchType>(
                      onSelected: (type) async {
                        if (type == MatchType.Random) {
                          List<UserModel> users = await ListeningSongService()
                              .getFutureListenersFrom(song!.id);
                          if (users.isNotEmpty) {
                            users.shuffle();
                            print("Conencting User= " + users.first.toString());
                            showUserDialog(users.first);
                          }
                        } else {
                          showListeningUsers(song!.id);
                        }
                      },
                      icon: Icon(Icons.person_search_rounded, size: 30),
                      itemBuilder: (s) {
                        return [
                          PopupMenuItem(
                            child: Text("Rastgele Eşleş"),
                            value: MatchType.Random,
                          ),
                          PopupMenuItem(
                            child: Text("Kendin Seç"),
                            value: MatchType.YourSelect,
                          ),
                        ];
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void showListeningUsers(String songId) {
    showModalBottomSheet(
        context: context,
        builder: (c) {
          AuthService authService = AuthService();
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: ListeningSongService().getStreamListenersFrom(songId),
            builder: (c, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (c, i) {
                  print(snapshot.data!.docs[i].id);
                  return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: authService
                        .getUserStreamFromId(snapshot.data!.docs[i].id),
                    builder: (c, snap) {
                      if (!snap.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snap.data == null) {
                        return Text("null");
                      }
                      UserModel user = UserModel.fromMap(snap.data!.data()!);
                      if (user.id == FirebaseAuth.instance.currentUser!.uid) {
                        return SizedBox();
                      }
                      if (!(user.connectionType?.isReady ?? false)) {
                        return SizedBox();
                      }
                      return ListTile(
                        onTap: () {
                          AuthService().sendMatchRequest(user.id!);
                          Navigator.pop(context);
                        },
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(user.image!),
                        ),
                        title: Text(user.userName ?? "User Name"),
                        subtitle: Text(user.bio ?? "Biografi"),
                      );
                    },
                  );
                },
              );
            },
          );
        });
  }

  AspectRatio buildImageWidget() {
    return AspectRatio(
      aspectRatio: 1,
      child: Card(
        margin: EdgeInsets.zero,
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
    );
  }

  StreamMediaItem buildActionsWidget() {
    return StreamMediaItem(
      builder: (song) {
        return Row(
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
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.loose(Size.square(20)),
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
            Spacer(),
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
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 30,
                      ),
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
            Spacer(),
            StreamBuilder<AudioServiceRepeatMode>(
              stream: handler.playbackState
                  .map((event) => event.repeatMode)
                  .distinct(),
              builder: (context, snapshot) {
                return IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.loose(Size.square(20)),
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
      height: 40,
      width: double.maxFinite,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 6,
            left: 6,
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
          Positioned(
            top: 15,
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

  Widget buildTitleWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
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

  void showUserDialog(UserModel user) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title:
                Text((user.userName ?? "User") + " ile eşleşmek ister misin?"),
            content: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.image!),
              ),
              title: Text(user.userName ?? "User"),
              subtitle: Text(
                user.bio ?? "Biografi",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    AuthService().sendMatchRequest(user.id!);
                    Navigator.pop(context);
                  },
                  child: Text("Eşleş")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Eşleşme")),
            ],
          );
        });
  }
}

enum MatchType { Random, YourSelect }
