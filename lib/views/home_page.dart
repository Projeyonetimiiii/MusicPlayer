import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/models/head_music.dart';
import 'package:onlinemusic/models/youtube_genre.dart';
import 'package:onlinemusic/models/youtube_musics.dart';
import 'package:onlinemusic/models/youtube_playlist.dart';
import 'package:onlinemusic/providers/data.dart';
import 'package:onlinemusic/services/auth.dart';
import 'package:onlinemusic/services/theme_service.dart';
import 'package:onlinemusic/services/youtube_service.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/playing_screen/playing_screen.dart';
import 'package:onlinemusic/views/playlist_screen/playlist_all_items_screen.dart';
import 'package:onlinemusic/views/profile_screen/profile_screen.dart';
import 'package:onlinemusic/views/search_screen.dart';
import 'package:onlinemusic/views/users_screen.dart';
import 'package:onlinemusic/views/playlist_screen/yt_playlist_screen.dart';
import 'package:onlinemusic/widgets/favorite_animation.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/usermodel.dart';

YoutubeMusics? _youtubeMusics =
    cacheBox!.get("youtubeMusics", defaultValue: null) != null
        ? YoutubeMusics.fromJson(cacheBox!.get("youtubeMusics")!)
        : null;

class YoutubeHomePage extends StatefulWidget {
  const YoutubeHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<YoutubeHomePage> createState() => _HomePageState();
}

class _HomePageState extends State<YoutubeHomePage>
    with AutomaticKeepAliveClientMixin<YoutubeHomePage> {
  YoutubeExplode yt = YoutubeExplode();
  final _currentPageNotifier = ValueNotifier<int>(0);
  List<YoutubeGenre> genres = [];
  List<HeadMusic> headSongs = [];
  late PageController _pageController;
  int selectedGenreId = 1;
  Timer? timer;
  bool showHeadMusic = true;
  bool isLoading = false;
  TextEditingController controller = TextEditingController();
  bool isLightTheme = ThemeService().isLight;
  late MyData data;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    data = context.myData;
    genres = _youtubeMusics?.genres ?? [];
    headSongs = _youtubeMusics?.headSongs ?? [];
    _pageController = PageController();

    services.getMusicHome().then(
      (value) {
        if (value != null) {
          _youtubeMusics = value;
          cacheBox!.put("youtubeMusics", value.toJson());
          genres = value.genres ?? genres;
          headSongs = value.headSongs ?? headSongs;
          if (mounted) setState(() {});

          if (headSongs.isNotEmpty)
            WidgetsBinding.instance.addPostFrameCallback(
              (timeStamp) {
                if (headSongs.isNotEmpty) {
                  timer = Timer.periodic(
                    Duration(seconds: 10),
                    (timer) {
                      nextPage();
                    },
                  );
                }
              },
            );
        }
      },
    );
  }

  void nextPage() {
    if (_currentPageNotifier.value < headSongs.length - 1) {
      if (_pageController.positions.isNotEmpty)
        _pageController.nextPage(
            duration: Duration(milliseconds: 350), curve: Curves.linear);
    } else {
      if (_pageController.positions.isNotEmpty)
        _pageController.animateToPage(0,
            duration: Duration(milliseconds: 350), curve: Curves.linear);
    }
  }

  @override
  void dispose() {
    yt.close();
    _currentPageNotifier.dispose();
    timer?.cancel();
    super.dispose();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (c, i) {
          return [
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Material(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(25),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(25),
                        ),
                        child: Container(
                          color:
                              isLightTheme ? Const.kBackground : Const.kWhite,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 50, top: 20),
                                child: Icon(
                                  Icons.multitrack_audio_rounded,
                                  size: 90,
                                  color: Const.themeColor.withOpacity(0.2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    width: double.maxFinite,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).padding.top + 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () async {
                                UserModel? userModel = await AuthService()
                                    .getUserFromId(
                                        FirebaseAuth.instance.currentUser!.uid);
                                if (userModel != null) {
                                  context.push(
                                      ProfileScreen(userModel: userModel));
                                }
                              },
                              child: Icon(
                                Icons.account_circle_rounded,
                                size: 35,
                                color: isLightTheme
                                    ? Const.kWhite
                                    : Const.kBackground,
                              ),
                            ),
                            Row(
                              children: [
                                ThemeListener(
                                  builder: (theme) {
                                    return InkWell(
                                      onTap: () {
                                        ThemeService().changeTheme();
                                        isLightTheme = ThemeService().isLight;
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((timeStamp) {
                                          nextPage();
                                        });
                                      },
                                      child: AnimatedCrossFade(
                                        duration: Duration(milliseconds: 350),
                                        crossFadeState: theme == ThemeMode.light
                                            ? CrossFadeState.showFirst
                                            : CrossFadeState.showSecond,
                                        firstChild: Icon(
                                          Icons.dark_mode_rounded,
                                          key: Key("icondark"),
                                          size: 20,
                                          color: Const.kWhite,
                                        ),
                                        secondChild: Icon(
                                          Icons.light_mode,
                                          key: Key("iconlight"),
                                          size: 20,
                                          color: Const.kBackground,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                StreamBuilder<UserModel?>(
                                  stream: AuthService().currentUser,
                                  builder: (context, snapshot) {
                                    if (snapshot.data?.isAdmin == true) {
                                      return IconButton(
                                        onPressed: () {
                                          context.push(UsersScreen());
                                        },
                                        iconSize: 25,
                                        icon: Icon(
                                          Icons.groups_outlined,
                                          color: isLightTheme
                                              ? Const.kWhite
                                              : Const.kBackground,
                                        ),
                                      );
                                    }
                                    return SizedBox();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          "Hoşgeldin",
                          style: TextStyle(
                            color:
                                isLightTheme ? Const.kWhite : Const.kBackground,
                            fontSize: 30,
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                        Text(
                          _auth.currentUser!.displayName!,
                          style: TextStyle(
                            color:
                                isLightTheme ? Const.kWhite : Const.kBackground,
                            fontSize: 46,
                            letterSpacing: 0.3,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          height: 36,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black45,
                                blurRadius: 3,
                                offset: Offset(0, 2),
                              ),
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: TextField(
                            onSubmitted: (c) {
                              if (c.trim().isNotEmpty) {
                                controller.clear();
                                context.push(SearchScreen(
                                  initialQuery: c,
                                ));
                              }
                            },
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.search,
                            cursorColor: Const.kBackground,
                            cursorWidth: 0.5,
                            controller: controller,
                            style: TextStyle(
                              color: Const.kBackground,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.2,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              isCollapsed: true,
                              border: InputBorder.none,
                              hintText: "Müzik ara",
                              hintStyle: TextStyle(
                                color: Const.kBackground.withOpacity(0.5),
                                fontSize: 15,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Const.kBackground,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
        body: getBody(),
      ),
    );
  }

  Widget getBody() {
    return ListView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 60, top: 20),
      children: [
        headSongs.isNotEmpty
            ? AnimatedCrossFade(
                firstChild: SizedBox(),
                secondChild: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.width / 2 + 50,
                      width: double.maxFinite,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: PageView.builder(
                            key: const PageStorageKey("headMusics"),
                            controller: _pageController,
                            physics: BouncingScrollPhysics(),
                            itemCount: headSongs.length,
                            onPageChanged: (s) {
                              _currentPageNotifier.value = s;
                            },
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (c, i) {
                              return InkWell(
                                onTap: () async {
                                  if (!isLoading) {
                                    isLoading = true;
                                    if (headSongs[i].firstItemId != null) {
                                      Video video = await YoutubeExplode()
                                          .videos
                                          .get(headSongs[i].firstItemId!);
                                      isLoading = false;
                                      context.pushOpaque(
                                        PlayingScreen(
                                          song: video.toMediaItem,
                                          queue: [video.toMediaItem],
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned.fill(
                                      right: 5,
                                      left: 5,
                                      top: 15,
                                      bottom: 10,
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              bottom: Radius.circular(12)),
                                        ),
                                        elevation: 0,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                              bottom: Radius.circular(12)),
                                          child: CachedNetworkImage(
                                            imageUrl: headSongs[i]
                                                .imageQuality(false),
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
                                    Positioned(
                                      top: 0,
                                      right: 9,
                                      left: 9,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Const.contrainsColor,
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(12),
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 7,
                                        ),
                                        width: double.infinity,
                                        child: Center(
                                          child: Text(
                                            headSongs[i].title ?? "",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Const.themeColor,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: ThemeListener(
                        builder: (theme) {
                          return Center(
                            child: SmoothPageIndicator(
                              controller: _pageController,
                              count: headSongs.length,
                              effect: ExpandingDotsEffect(
                                activeDotColor: Const.contrainsColor,
                                dotColor: Const.contrainsColor.withOpacity(0.3),
                                dotHeight: 10,
                                dotWidth: 10,
                                spacing: 15,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
                crossFadeState: showHeadMusic
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: Duration(milliseconds: 400),
              )
            : SizedBox(),
        getFavoriteSongs(),
        getFavoriteLists(),
        Column(
          children: genres.map((e) {
            return getYoutubeGenreWidget(e.title, e.playlists);
          }).toList(),
        ),
        StreamBuilder(
          stream: handler.mediaItem.map((event) => event != null).distinct(),
          builder: (c, isThereItem) {
            return StreamBuilder(
              stream: handler.playbackState
                  .map((event) =>
                      event.processingState == AudioProcessingState.idle)
                  .distinct(),
              builder: (c, isIdle) {
                if (isIdle.data == false && isThereItem.data == true) {
                  return SizedBox(
                    height: 60,
                  );
                }
                return SizedBox();
              },
            );
          },
        ),
      ],
    );
  }

  Widget getYoutubeGenreWidget(
    String? title,
    List<YoutubePlaylist>? lists, {
    bool finishAnimation = false,
  }) {
    if ((lists ?? []).isEmpty) {
      return SizedBox(
        key: GlobalKey(),
      );
    }

    bool isPlaylist = lists!.first.isPlaylist;

    return Column(
      key: GlobalKey(),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              child: RichText(
                text: TextSpan(
                  text: title,
                  style: TextStyle(
                    color: Const.contrainsColor,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: "  " +
                          lists.length.toString() +
                          (!isPlaylist ? " video" : " liste"),
                      style: TextStyle(
                        color: Const.kBackground,
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                context.push(
                  PlaylistAllItemsScreen(
                    title: title,
                    playlists: lists,
                  ),
                );
              },
              child: Text(
                "Hepsini gör",
                style: TextStyle(color: Const.contrainsColor),
              ),
            ),
          ],
        ),
        buildPlaylists(
          lists,
          finishAnimation: finishAnimation,
        ),
      ],
    );
  }

  Widget buildPlaylists(List<YoutubePlaylist> lists,
      {bool finishAnimation = false}) {
    Size size = MediaQuery.of(context).size;
    bool isPlaylist = lists.first.isPlaylist;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: IntrinsicHeight(
        child: Row(
          children: lists.map((myPlaylist) {
            return SizedBox(
              width: isPlaylist ? size.width / 3.5 : size.width / 2.5,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: InkWell(
                  splashColor: Const.kBackground,
                  radius: 0,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12),
                    bottom: Radius.circular(8),
                  ),
                  onTap: () {
                    context.push(YtPlaylistScreen(playlist: myPlaylist));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                        bottom: Radius.circular(8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Const.kBackground.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(-4, 4),
                        )
                      ],
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          FavoriteAnimation(
                            finishAnimationCallback: finishAnimation,
                            onDoubleTap: () {
                              data.changeFavoriteList(myPlaylist);
                            },
                            child: AspectRatio(
                              aspectRatio: myPlaylist.isPlaylist ? 1 : 16 / 9,
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: myPlaylist.getStandartImage,
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
                          Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(8),
                              ),
                              color: Const.kWhite,
                            ),
                            child: Center(
                              child: Text(
                                myPlaylist.title ?? "",
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget getFavoriteLists() {
    return StreamBuilder<List<YoutubePlaylist>>(
      stream: data.favoriteLists,
      initialData: data.favoriteLists.value,
      builder: (c, snap) {
        List<YoutubePlaylist> lists = snap.data!;
        Widget child = SizedBox(
          key: GlobalKey(),
        );
        if (lists.isNotEmpty) {
          child = getYoutubeGenreWidget("Favori Listelerim", lists,
              finishAnimation: true);
        }
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 350),
          child: child,
        );
      },
    );
  }

  Widget getFavoriteSongs() {
    Size size = MediaQuery.of(context).size;
    return StreamBuilder<List<MediaItem>>(
      stream: data.favoriteSongs,
      initialData: data.favoriteSongs.value,
      builder: (c, snap) {
        List<MediaItem> lists = snap.data!;
        Widget child = SizedBox(
          key: GlobalKey(),
        );
        if (lists.isNotEmpty) {
          child = Column(
            key: GlobalKey(),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    child: RichText(
                      text: TextSpan(
                        text: "Favori Müziklerim",
                        style: TextStyle(
                          color: Const.contrainsColor,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: "  " + lists.length.toString() + " müzik",
                            style: TextStyle(
                              color: Const.kBackground,
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.push(
                        PlaylistAllItemsScreen.fromSongs(
                          title: "Favori Müziklerim",
                          songs: lists,
                        ),
                      );
                    },
                    child: Text(
                      "Hepsini gör",
                      style: TextStyle(color: Const.contrainsColor),
                    ),
                  ),
                ],
              ),
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: IntrinsicHeight(
                  child: Row(
                    children: lists.map((e) {
                      return SizedBox(
                        width: size.width / 3.5,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            splashColor: Const.kBackground,
                            radius: 0,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                              bottom: Radius.circular(8),
                            ),
                            onTap: () {
                              context.pushOpaque(
                                PlayingScreen(
                                  song: e,
                                  queue: lists,
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12),
                                  bottom: Radius.circular(8),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Const.kBackground.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: Offset(-4, 4),
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  FavoriteAnimation(
                                    finishAnimationCallback: true,
                                    onDoubleTap: () {
                                      data.changeFavoriteSong(e);
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: e.getImageWidget,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.vertical(
                                        bottom: Radius.circular(8),
                                      ),
                                      color: Const.kWhite,
                                    ),
                                    child: Center(
                                      child: Text(
                                        e.title,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color.fromARGB(255, 0, 0, 0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        }
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 350),
          child: child,
        );
      },
    );
  }
}
