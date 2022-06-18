import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/models/connected_controller.dart';
import 'package:onlinemusic/models/connected_song_model.dart';
import 'package:onlinemusic/models/usermodel.dart';
import 'package:onlinemusic/providers/data.dart';
import 'package:onlinemusic/services/auth.dart';
import 'package:onlinemusic/services/connected_song_service.dart';
import 'package:onlinemusic/services/listening_song_service.dart';
import 'package:onlinemusic/services/messages_service.dart';
import 'package:onlinemusic/services/user_status_service.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/enums.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/playing_screen/widgets/my_popup_divider.dart';
import 'package:onlinemusic/views/playing_screen/widgets/seekbar.dart';
import 'package:onlinemusic/views/playing_screen/widgets/stream_media_item.dart';
import 'package:onlinemusic/views/profile_screen/profile_screen.dart';
import 'package:onlinemusic/views/playing_screen/queue_screen.dart';
import 'package:onlinemusic/widgets/my_overlay_notification.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../chat/messages/message_screen.dart';
import '../video_player_screen.dart';

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
  GlobalKey popupKey = GlobalKey();
  StreamSubscription? controllerSubscription;

  MediaItem? get song => widget.song;
  MyData get myData => context.myData;

  @override
  void initState() {
    super.initState();
    PlayingScreen.isRunning = true;
    isFavorite =
        myData.favoriteSongs.value.any((element) => element.id == song?.id);
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
    if (connectedSongService.isAdmin) {
      if (updateQueue) {
        await this.updateQueue();
      }
      MediaItem? newItem = mediaItem ?? song;
      if (newItem != null) {
        await handler.playMediaItem(newItem);
        if (!connectedSongService.isConnectedSong) {
          await handler.play();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey("playing"),
      direction: DismissDirection.down,
      background: Container(color: Colors.transparent),
      behavior: HitTestBehavior.translucent,
      onDismissed: (s) {
        Navigator.pop(context);
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: StreamBuilder<ConnectedSongModel?>(
          stream: connectedSongService.connectSongModel,
          initialData: connectedSongService.connectSongModel.value,
          builder: (context, songSnapshot) {
            return StreamBuilder<bool?>(
                stream: ConnectedSongService()
                    .controller
                    .map((event) => event?.isReady)
                    .distinct(),
                initialData: ConnectedSongService().controller.value?.isReady,
                builder: (context, controllerSnapshot) {
                  bool isReady = true;
                  if (songSnapshot.data?.isAdmin == true) {
                    isReady = (controllerSnapshot.data ?? true);
                  }
                  return playingScreenBody(
                      context, connectedSongService.isAdmin, isReady);
                });
          },
        ),
      ),
    );
  }

  Widget get isLoadingWidget {
    try {
      handler.pause();
    } on Exception catch (_) {}
    return Positioned.fill(
      child: Container(
        color: Colors.black38,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Diğer kullanıcının ayarları yapılıyor lütfen bekleyiniz",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Center(
                  child: CircularProgressIndicator(
                color: Colors.white,
              )),
            ],
          ),
        ),
      ),
    );
  }

  PageView playingScreenBody(BuildContext context, bool isAdmin, bool isReady) {
    bool absorbing = isAdmin ? !isReady : true;
    return PageView(
      controller: pageController,
      children: [
        SafeArea(
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: buildTopActions(),
                  ),
                  buildImageWidget(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: buildTitleWidget(),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: AnimatedOpacity(
                      duration: Duration(milliseconds: 250),
                      opacity: !absorbing ? 1 : 0.6,
                      child: AbsorbPointer(
                        absorbing: absorbing,
                        child: Column(
                          children: [
                            buildSliderWidget(),
                            buildActionsWidget(),
                          ],
                        ),
                      ),
                    ),
                  ),
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
                if (isAdmin) {
                  setMediaItem(mediaItem: newSong);
                }
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
    );
  }

  Widget buildTopActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: SizedBox(
        height: 40,
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
                isFavorite = myData.favoriteSongs.value
                    .any((element) => element == song);
                Widget? favoriteChild;
                Widget? listenerCount;

                if (song != null) {
                  listenerCount =
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: ListeningSongService().getStreamListenersFrom(
                      song.id,
                    ),
                    builder: (c, snap) {
                      if (snap.hasData) {
                        List<String> filtered = snap.data!.docs
                            .map((e) => e.data()["userId"].toString())
                            .toList();
                        filtered.removeWhere((element) =>
                            element == FirebaseAuth.instance.currentUser!.uid);
                        if (filtered.isNotEmpty) {
                          return Text(
                              filtered.length.toString() + " Dinleyici");
                        }
                      }
                      return SizedBox();
                    },
                  );
                } else {
                  listenerCount = SizedBox();
                }

                if (isFavorite) {
                  favoriteChild = Text(
                    "Favori Müziğim",
                    style: TextStyle(
                      color: Const.kBackground,
                      fontSize: 14,
                    ),
                  );
                } else {
                  favoriteChild = SizedBox();
                }
                return AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!(favoriteChild is SizedBox)) favoriteChild,
                      if (!(listenerCount is SizedBox)) listenerCount,
                    ],
                  ),
                );
              },
            ),
            Spacer(),
            StreamMediaItem(
              builder: (song) {
                return Row(
                  children: [
                    StreamBuilder<UserModel?>(
                      stream: AuthService().currentUser,
                      initialData: AuthService().currentUser.value,
                      builder: (c, snap) {
                        Widget? child;
                        if (!snap.hasData) {
                          child = SizedBox();
                        } else {
                          UserModel user = snap.data!;

                          child = StreamBuilder<
                              DocumentSnapshot<Map<String, dynamic>>>(
                            stream: user.connectedUserId == null
                                ? null
                                : AuthService()
                                    .getUserStreamFromId(user.connectedUserId!),
                            builder: (c, snap) {
                              Widget? child;
                              PopupMenuItem<PopupEnum>? userPopupMenuItem;
                              UserModel? connectedUser;
                              if (snap.hasData &&
                                  user.connectedUserId != null) {
                                connectedUser =
                                    UserModel.fromMap(snap.data!.data()!);
                                userPopupMenuItem = PopupMenuItem<PopupEnum>(
                                  value: PopupEnum.Profile,
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(connectedUser.userName!),
                                      Spacer(),
                                      CircleAvatar(
                                        backgroundColor: Colors.grey.shade300,
                                        radius: 14,
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                          connectedUser.image!,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              child = PopupMenuButton<PopupEnum>(
                                key: popupKey,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                onSelected: (s) {
                                  onSelected(s, connectedUser, song);
                                },
                                itemBuilder: (_) {
                                  return [
                                    if (userPopupMenuItem == null) ...[
                                      if (song?.isOnline == true)
                                        PopupMenuItem(
                                          value: PopupEnum.Match,
                                          textStyle: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.person_add_alt_rounded,
                                                size: 16,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text("Eşleş"),
                                              Spacer(),
                                              Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                size: 16,
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                    if (song?.type.isVideo ?? true)
                                      PopupMenuItem(
                                        value: PopupEnum.ViewVideo,
                                        textStyle: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.videocam,
                                              size: 16,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text("Video İzle"),
                                          ],
                                        ),
                                      ),
                                    if (!connectedSongService.isConnectedSong ||
                                        connectedSongService.isAdmin)
                                      PopupMenuItem(
                                        value: PopupEnum.Timer,
                                        textStyle: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.timer_sharp,
                                              size: 16,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text("Zamanlayıcı Kur"),
                                          ],
                                        ),
                                      ),
                                    if (userPopupMenuItem != null) ...[
                                      PopupMenuItem(
                                        value: PopupEnum.Message,
                                        textStyle: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.message_rounded,
                                              size: 16,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text("Mesaj At"),
                                          ],
                                        ),
                                      ),
                                      if (user.connectedSongModel == null &&
                                          (song?.isOnline ?? true) &&
                                          (connectedUser?.isOnline ?? false))
                                        PopupMenuItem(
                                          value: PopupEnum.SongMatch,
                                          textStyle: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.audiotrack_rounded,
                                                size: 16,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text("Müziği Eşleştir"),
                                            ],
                                          ),
                                        ),
                                      if (user.connectedSongModel != null)
                                        PopupMenuItem(
                                          value: PopupEnum.SongUnMatch,
                                          textStyle: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.audiotrack_rounded,
                                                size: 16,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text("Müziğin Eşleşmesini Bitir"),
                                            ],
                                          ),
                                        ),
                                      MyPopupMenuDivider(
                                        tickness: 3,
                                        height: 3,
                                        color: Colors.grey.shade200,
                                      ),
                                      userPopupMenuItem,
                                      PopupMenuItem(
                                        value: PopupEnum.UnMatch,
                                        textStyle: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Eşleşmeyi Bitir",
                                            style: TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ];
                                },
                              );
                              return AnimatedSwitcher(
                                duration: Duration(milliseconds: 250),
                                child: child,
                              );
                            },
                          );
                        }

                        return AnimatedSwitcher(
                          duration: Duration(milliseconds: 250),
                          child: child,
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void showListeningUsers(String songId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade200,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (c) {
        AuthService authService = AuthService();
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: ListeningSongService().getStreamListenersFrom(songId),
            builder: (c, snapshot) {
              if (!snapshot.hasData) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Const.kBackground,
                    ),
                  ),
                );
              }

              if (snapshot.data!.docs.isEmpty) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Text("Burada hiç kullanıcı yok :("),
                  ),
                );
              }

              return ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (c, i) {
                  return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: authService
                        .getUserStreamFromId(snapshot.data!.docs[i].id),
                    builder: (c, snap) {
                      if (!snap.hasData) {
                        return Center(
                          child: Text(""),
                        );
                      }
                      if (snap.data == null) {
                        return Text("");
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
                          AuthService().sendUserMatchRequest(user.id!);
                          Navigator.pop(context);
                        },
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage:
                              CachedNetworkImageProvider(user.image!),
                        ),
                        title: Text(user.userName ?? "User Name"),
                        subtitle: Text(user.bio ?? "Biografi"),
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget buildImageWidget() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 10,
          right: 16,
          left: 16,
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 32,
          child: Center(
            child: StreamMediaItem(
              builder: (song) {
                if (song == null) return SizedBox();

                Widget? child;
                if (!song.isOnline) {
                  child = Hero(
                    tag: "currentArtwork",
                    child: Image(
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width - 32,
                      gaplessPlayback: true,
                      image: FileImage(
                        File(
                          song.artUri!.toFilePath(),
                        ),
                      ),
                    ),
                  );
                } else {
                  child = Hero(
                    tag: "currentArtwork",
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: song.maxImageUrl,
                      placeholder: (_, __) {
                        return Image(
                          fit: BoxFit.cover,
                          image: AssetImage(
                            "assets/images/default_song_image.png",
                          ),
                        );
                      },
                      errorWidget: (_, __, ___) {
                        return song.getImageWidget;
                      },
                      width: MediaQuery.of(context).size.width - 32,
                    ),
                  );
                }

                if (song.type.isVideo) {
                  child = AspectRatio(
                    aspectRatio: 16 / 9,
                    child: child,
                  );
                }

                if (song.type.isAudio) {
                  child = AspectRatio(
                    aspectRatio: 1,
                    child: child,
                  );
                }

                return GestureDetector(
                  onDoubleTap: () {
                    if (isFavorite) {
                      myData.removeFavoritedSong(song);
                    } else {
                      myData.addFavoriteSong(song);
                    }
                    setState(() {});
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    clipBehavior: Clip.antiAlias,
                    margin: EdgeInsets.zero,
                    elevation: 8,
                    child: child,
                  ),
                );
              },
            ),
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
                  icon: Icon(Icons.shuffle_rounded),
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
                  icon: Icon(Icons.skip_previous_rounded, size: 35),
                ),
                StreamBuilder<bool>(
                    stream: handler.player.processingStateStream
                        .map((event) => event == ProcessingState.ready)
                        .distinct(),
                    initialData: false,
                    builder: (context, snapshot) {
                      bool isReady = snapshot.data!;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 65,
                            height: 65,
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Const.kWhite,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: StreamBuilder<bool>(
                              stream: handler.playingStream,
                              builder: (context, snapshot) {
                                bool isPlaying = snapshot.data ?? false;
                                return IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () async {
                                    if (isPlaying) {
                                      handler.pause();
                                    } else {
                                      handler.play();
                                    }
                                  },
                                  icon: Icon(
                                    isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    size: 45,
                                  ),
                                );
                              },
                            ),
                          ),
                          if (!isReady) ...[
                            SizedBox(
                              width: 65,
                              height: 65,
                              child: CircularProgressIndicator(
                                color: Const.kBackground,
                              ),
                            ),
                          ],
                        ],
                      );
                    }),
                IconButton(
                  onPressed: !handler.hasNext
                      ? null
                      : () async {
                          await handler.skipToNext();
                          handler.play();
                        },
                  icon: Icon(
                    Icons.skip_next_rounded,
                    size: 35,
                  ),
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
      height: 50,
      width: double.maxFinite,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 16,
            left: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder<Duration>(
                    stream: AudioService.position,
                    builder: (context, snapshot) {
                      return Text(
                        Const.getDurationString(
                            handler.playbackState.value.position),
                        style: TextStyle(fontSize: 12),
                      );
                    }),
                StreamMediaItem(
                  builder: (song) {
                    return Text(
                      Const.getDurationString(
                        song?.duration ?? Duration.zero,
                      ),
                      style: TextStyle(fontSize: 12),
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            right: 16,
            left: 10,
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

  StreamMediaItem buildTitleWidget() {
    return StreamMediaItem(
      builder: (song) {
        isFavorite = myData.favoriteSongs.value.any((e) => e.id == song?.id);
        return Container(
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: "title",
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    song?.title.trim() ?? "Title",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Hero(
                    tag: "artist",
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        song?.artist ?? "Artist",
                        style: TextStyle(
                          fontSize: 12,
                          color: Const.kBackground,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      if (isFavorite) {
                        myData.removeFavoritedSong(song!);
                      } else {
                        myData.addFavoriteSong(song!);
                      }
                      setState(() {});
                    },
                    icon: AnimatedSwitcher(
                      duration: Duration(milliseconds: 350),
                      child: Icon(
                        isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border_rounded,
                        color: isFavorite
                            ? Colors.redAccent
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void showUserDialog(UserModel user) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.grey.shade200,
            title:
                Text((user.userName ?? "User") + " ile eşleşmek ister misin?"),
            content: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                backgroundImage: CachedNetworkImageProvider(user.image!),
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
                    AuthService().sendUserMatchRequest(user.id!);
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

  void showUnMatchDialog(UserModel user) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: Colors.grey.shade200,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text("Emin misin?"),
            content: Text((user.userName ?? "User") +
                " ile eşleşmeni kapatmak istediğine emin misin?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Hayır")),
              TextButton(
                  onPressed: () async {
                    UserStatusService().disconnectUser(user.id!);
                    Navigator.pop(context);
                  },
                  child: Text("Evet")),
            ],
          );
        });
  }

  Future<MatchType?> showMatchMenu() async {
    final PopupMenuThemeData popupMenuTheme = PopupMenuTheme.of(context);
    final RenderBox button =
        popupKey.currentContext!.findRenderObject()! as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero) + Offset.zero,
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    return showMenu<MatchType?>(
      context: context,
      elevation: popupMenuTheme.elevation,
      items: [
        PopupMenuItem(
          child: Text("Rastgele Eşleş"),
          value: MatchType.Random,
        ),
        PopupMenuItem(
          child: Text("Kendin Seç"),
          value: MatchType.YourSelect,
        ),
      ],
      position: position,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: popupMenuTheme.color,
    );
  }

  Future<void> setTimer() {
    Duration _time = Duration.zero;
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: Colors.grey.shade200,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Center(
            child: Text(
              "Zaman seçin",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Const.kBackground,
              ),
            ),
          ),
          children: [
            Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    primaryColor: Const.kBackground,
                    textTheme: CupertinoTextThemeData(
                      pickerTextStyle: TextStyle(
                        fontSize: 16,
                        color: Const.kBackground,
                      ),
                    ),
                  ),
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hm,
                    onTimerDurationChanged: (value) {
                      _time = value;
                    },
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    primary: Const.kBackground.withOpacity(0.7),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("İptal Et"),
                ),
                const SizedBox(
                  width: 10,
                ),
                TextButton(
                  onPressed: () {
                    sleepTimer(_time.inMinutes);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            "Zamanlayıcı ${_time.inMinutes} dakikaya ayarlandı")));
                  },
                  child: Text("Kaydet"),
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void sleepTimer(int minute) {
    handler.customAction("sleepTimer", {"time": minute});
  }

  void onSelected(PopupEnum value, UserModel? user, MediaItem? song) async {
    switch (value) {
      case PopupEnum.Match:
        MatchType? type = await showMatchMenu();
        if (song == null) return;
        if (type == MatchType.Random) {
          List<UserModel> users =
              await ListeningSongService().getFutureListenersFrom(song.id);
          if (users.isNotEmpty) {
            if (users.length < 1) {
              showMyOverlayNotification(
                duration: Duration(seconds: 2),
                message: "Hiç kimse yok",
                isDismissible: true,
              );
              return;
            }
            users.shuffle();

            showUserDialog(users.first);
          }
        } else if (type == MatchType.YourSelect) {
          showListeningUsers(song.id);
        }
        break;
      case PopupEnum.UnMatch:
        if (user != null) showUnMatchDialog(user);
        break;
      case PopupEnum.Message:
        if (user != null)
          context.push(
            MessagesScreen(
              user: user,
            ),
          );
        break;
      case PopupEnum.Profile:
        if (user != null) context.push(ProfileScreen(userModel: user));
        break;
      case PopupEnum.SongMatch:
        if (user != null) AuthService().sendSongMatchRequest(user.id!);
        break;
      case PopupEnum.SongUnMatch:
        if (user != null) UserStatusService().disconnectUserSong(user.id!);
        break;
      case PopupEnum.ViewVideo:
        StreamManifest url =
            await yt.videos.streamsClient.getManifest(song!.id);
        context.push(
          VideoPlayerScreen(
            isLocal: false,
            url: url.muxed.bestQuality.url.toString(),
          ),
        );
        break;
      case PopupEnum.Timer:
        await setTimer();
        break;
      default:
        print("işlem yok" + value.toString());
    }
  }
}
