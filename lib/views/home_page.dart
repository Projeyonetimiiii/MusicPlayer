import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/models/audio.dart';
import 'package:onlinemusic/models/genre.dart';
import 'package:onlinemusic/models/head_music.dart';
import 'package:onlinemusic/models/youtube_genre.dart';
import 'package:onlinemusic/models/youtube_musics.dart';
import 'package:onlinemusic/models/youtube_playlist.dart';
import 'package:onlinemusic/services/audios_bloc.dart';
import 'package:onlinemusic/services/auth.dart';
import 'package:onlinemusic/services/youtube_service.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/playing_screen/playing_screen.dart';
import 'package:onlinemusic/views/playlist_screen/playlist_screen.dart';
import 'package:onlinemusic/views/profile_screen/profile_screen.dart';
import 'package:onlinemusic/views/search_screen.dart';
import 'package:onlinemusic/views/users_screen.dart';
import 'package:onlinemusic/views/playlist_screen/yt_playlist_screen.dart';
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

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    genres = _youtubeMusics?.genres ?? [];
    headSongs = _youtubeMusics?.headSongs ?? [];
    _pageController = PageController();

    services.getMusicHome().then((value) {
      if (value != null) {
        _youtubeMusics = value;
        cacheBox!.put("youtubeMusics", value.toJson());
        genres = value.genres ?? genres;
        headSongs = value.headSongs ?? headSongs;
        if (mounted) setState(() {});

        if (headSongs.isNotEmpty)
          WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
            if (headSongs.isNotEmpty) {
              timer = Timer.periodic(Duration(seconds: 10), (timer) {
                if (_currentPageNotifier.value < headSongs.length - 1) {
                  if (_pageController.positions.isNotEmpty)
                    _pageController.nextPage(
                        duration: Duration(milliseconds: 350),
                        curve: Curves.linear);
                } else {
                  if (_pageController.positions.isNotEmpty)
                    _pageController.animateToPage(0,
                        duration: Duration(milliseconds: 350),
                        curve: Curves.linear);
                }
              });
            }
          });
      }
    });
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
                          color: Const.kBackground,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 32),
                                child: Icon(
                                  Icons.multitrack_audio_rounded,
                                  size: 100,
                                  color: Colors.white30,
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
                                color: Colors.white,
                              ),
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
                                      color: Colors.white,
                                    ),
                                  );
                                }
                                return SizedBox();
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          "Hoşgeldin",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w200),
                        ),
                        Text(
                          _auth.currentUser!.displayName!,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 46,
                              letterSpacing: 0.3,
                              fontWeight: FontWeight.w900),
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
      padding: EdgeInsets.only(bottom: 120, top: 20),
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
                                        shadowColor:
                                            Const.kBackground.withOpacity(0),
                                        elevation: 6,
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
                                          color: Const.kBackground,
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
                                              color: Colors.white,
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
                      child: Center(
                        child: SmoothPageIndicator(
                          controller: _pageController,
                          count: headSongs.length,
                          effect: ExpandingDotsEffect(
                            activeDotColor: Const.kBackground,
                            dotColor: Const.kBackground.withOpacity(0.2),
                            dotHeight: 10,
                            dotWidth: 10,
                            spacing: 15,
                          ),
                        ),
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
        headTextWidget("Paylaşılan Müzikler"),
        Container(
          margin: EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            color: Const.kWhite,
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: getGenres(Const.genres),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: getGenreWidget(selectedGenreId),
              ),
            ],
          ),
        ),
        headTextWidget("Youtube Müzik"),
        Column(
          children: genres.map((e) {
            return getYoutubeGenreWidget(e);
          }).toList(),
        ),
      ],
    );
  }

  Widget getGenreWidget(int genreId) {
    Size size = MediaQuery.of(context).size;
    return StreamBuilder<List<Audio>>(
      stream: AudiosBloc().audiosSubject,
      initialData: AudiosBloc().audioList,
      builder: (context, snapshot) {
        Widget? child;
        if (!snapshot.hasData) {
          child = SizedBox();
        } else {
          List<Audio> audios = snapshot.data!
              .where((element) =>
                  element.genreIds.any((element) => element == genreId))
              .toList();
          if (audios.isEmpty) {
            child = SizedBox();
          } else {
            Genre genre =
                Const.genres.firstWhere((element) => element.id == genreId);
            child = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Text(
                        genre.name,
                        style: TextStyle(
                          color: Const.kBackground,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push(
                          PlaylistScreen.Genre(
                            genre: genre,
                          ),
                        );
                      },
                      child: Text(
                        audios.length.toString() + " müzik",
                        style: TextStyle(color: Const.kBackground),
                      ),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  scrollDirection: Axis.horizontal,
                  child: IntrinsicHeight(
                    child: Row(
                      children: audios.map((audio) {
                        return Container(
                          width: size.width / 3.5,
                          margin: EdgeInsets.symmetric(horizontal: 8),
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
                              ]),
                          child: RawMaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                                bottom: Radius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              context.pushOpaque(
                                PlayingScreen(
                                  song: audio.toMediaItem,
                                  queue:
                                      audios.map((e) => e.toMediaItem).toList(),
                                ),
                              );
                            },
                            child: IntrinsicHeight(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AspectRatio(
                                    aspectRatio: 1,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(12)),
                                      child: CachedNetworkImage(
                                        imageUrl: audio.image,
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
                                  Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                        bottom: Radius.circular(8),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        audio.title,
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
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            );
          }
        }
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 350),
          child: child,
        );
      },
    );
  }

  Widget getYoutubeGenreWidget(YoutubeGenre youtubeGenre) {
    if ((youtubeGenre.playlists ?? []).isEmpty) {
      return SizedBox();
    }

    Size size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              child: RichText(
                text: TextSpan(
                    text: youtubeGenre.title!,
                    style: TextStyle(
                      color: Const.kBackground,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    children: [
                      TextSpan(
                        text: "  " +
                            youtubeGenre.playlists!.length.toString() +
                            (!youtubeGenre.playlists!.first.isPlaylist
                                ? " video"
                                : " liste"),
                        style: TextStyle(
                            color: Const.kBackground,
                            fontSize: 12,
                            fontWeight: FontWeight.w300),
                      ),
                    ]),
              ),
            ),
            TextButton(
              onPressed: () {
                context.push(
                  PlaylistScreen.YoutubeGenre(youtubeGenre: youtubeGenre),
                );
              },
              child: Text(
                "Hepsini gör",
                style: TextStyle(color: Const.kBackground),
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
              children: youtubeGenre.playlists!.map((myPlaylist) {
                return SizedBox(
                  width: youtubeGenre.playlists!.length > 4
                      ? youtubeGenre.playlists!.first.isPlaylist
                          ? size.width / 3.5
                          : size.width / 2.5
                      : (size.width - 32) / youtubeGenre.playlists!.length,
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
                            ]),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              AspectRatio(
                                aspectRatio: myPlaylist.isPlaylist ? 1 : 16 / 9,
                                child: Builder(
                                  builder: (context) {
                                    return ClipRRect(
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
                                    );
                                  },
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
        ),
      ],
    );
  }

  Padding headTextWidget(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 18, right: 10, left: 10, bottom: 0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Const.kBackground,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getGenres(List<Genre> genres) {
    return StreamBuilder<List<Audio>>(
      stream: AudiosBloc().audiosSubject,
      initialData: AudiosBloc().audioList,
      builder: (context, snapshot) {
        return Container(
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Text(
                    "Kategoriler",
                    style: TextStyle(
                      color: Const.kBackground,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  child: IntrinsicHeight(
                    child: Row(
                      children: genres.map((e) {
                        List<Audio> audios =
                            AudiosBloc().getAudiosFromGenreId(e.id);
                        bool isSelectedGenre = selectedGenreId == e.id;
                        return audios.isEmpty
                            ? SizedBox()
                            : IntrinsicHeight(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        selectedGenreId = e.id;
                                        setState(() {});
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: 75,
                                            width: 75,
                                            margin: EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image:
                                                    CachedNetworkImageProvider(
                                                  audios.first.image,
                                                ),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          Positioned(
                                            left: 8,
                                            top: 12,
                                            child: Container(
                                              height: 75,
                                              width: 75,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: isSelectedGenre
                                                    ? Colors.black38
                                                    : Colors.black
                                                        .withOpacity(0.75),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  e.name,
                                                  style: TextStyle(
                                                    fontSize: isSelectedGenre
                                                        ? 19
                                                        : 15,
                                                    color: isSelectedGenre
                                                        ? Colors.white
                                                        : Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      audios.length.toString() + "  Müzik",
                                      style: TextStyle(
                                        fontSize: 12,
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
