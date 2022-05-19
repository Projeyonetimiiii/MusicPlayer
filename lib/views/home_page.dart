import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/models/audio.dart';
import 'package:onlinemusic/models/genre.dart';
import 'package:onlinemusic/models/head_music.dart';
import 'package:onlinemusic/models/youtube_genre.dart';
import 'package:onlinemusic/models/youtube_playlist.dart';
import 'package:onlinemusic/services/youtube_service.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/playing_screen/playing_screen.dart';
import 'package:onlinemusic/views/profile_screen.dart';
import 'package:page_view_indicators/page_view_indicators.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/usermodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _YoutubeHomePageState();
}

class _YoutubeHomePageState extends State<HomePage> {
  YoutubeExplode yt = YoutubeExplode();
  final _currentPageNotifier = ValueNotifier<int>(0);
  List<YoutubeGenre> genres = [];
  List<HeadMusic> headSongs = [];
  late PageController _pageController;
  Timer? timer;
  bool showHeadMusic = true;

  @override
  void initState() {
    super.initState();
    genres = [];
    headSongs = [];
    _pageController = PageController();

    services.getMusicHome().then((value) {
      if (value != null) {
        genres = value.genres ?? [];
        headSongs = value.headMusics ?? [];
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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ana Sayfa"),
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore
                .collection("Users")
                .doc(_auth.currentUser!.uid)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<DocumentSnapshot> veri) {
              if (veri.hasData) {
                UserModel userModel = UserModel.fromMap(
                    veri.data!.data() as Map<String, dynamic>);

                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) =>
                                ProfileScreen(userModel: userModel)));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        child: userModel.image == null
                            ? CircleAvatar(
                                maxRadius: 25,
                                child:
                                    Icon(Icons.supervised_user_circle_outlined),
                              )
                            : userModel.image!.isNotEmpty
                                ? CircleAvatar(
                                    maxRadius: 25,
                                    backgroundImage:
                                        NetworkImage(userModel.image!),
                                  )
                                : CircleAvatar(
                                    maxRadius: 25,
                                    child: Icon(
                                        Icons.supervised_user_circle_outlined),
                                  )),
                  ),
                );
              } else {
                return CircleAvatar(
                  maxRadius: 30,
                  child: Icon(Icons.supervised_user_circle_outlined),
                );
              }
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: 8, top: 16),
          children: [
            headSongs.isNotEmpty
                ? AnimatedCrossFade(
                    firstChild: SizedBox(),
                    secondChild: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.width / 2 + 20,
                          width: double.maxFinite,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
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
                                    //? oynatma ekranına gidilecek
                                  },
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        right: 5,
                                        left: 5,
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          shadowColor:
                                              Const.kWhite.withOpacity(0.5),
                                          elevation: 2,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.network(
                                              headSongs[i].imageQuality(false),
                                              fit: BoxFit.cover,
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
                                            color: Colors.white,
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(
                                                12,
                                              ),
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 5,
                                          ),
                                          width: double.infinity,
                                          child: Center(
                                            child: Text(
                                              headSongs[i].title ?? "",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 15,
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
                        Positioned(
                          bottom: -13,
                          right: 0,
                          left: 0,
                          child: CirclePageIndicator(
                            selectedSize: 8,
                            selectedDotColor: Const.kWhite.withOpacity(0.7),
                            dotColor: Const.kWhite.withOpacity(0.1),
                            currentPageNotifier: _currentPageNotifier,
                            itemCount: headSongs.length,
                          ),
                        ),
                      ],
                    ),
                    crossFadeState: showHeadMusic
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: Duration(milliseconds: 400),
                  )
                : SizedBox(),
            Column(
              children: Const.genres.map((e) {
                return getGenreWidget(e);
              }).toList(),
            ),
            Column(
              children: genres.map((e) {
                return getYoutubeGenreWidget(e);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget getBody() {
    return SafeArea(
      child: ListView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 8, top: 16),
        children: [
          headSongs.isNotEmpty
              ? AnimatedCrossFade(
                  firstChild: SizedBox(),
                  secondChild: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.width / 2 + 20,
                        width: double.maxFinite,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
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
                                  //? oynatma ekranına gidilecek
                                },
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      right: 5,
                                      left: 5,
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        shadowColor:
                                            Const.kWhite.withOpacity(0.5),
                                        elevation: 2,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.network(
                                            headSongs[i].imageQuality(false),
                                            fit: BoxFit.cover,
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
                                          color: Colors.white,
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 5,
                                        ),
                                        width: double.infinity,
                                        child: Center(
                                          child: Text(
                                            headSongs[i].title ?? "",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 15,
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
                      Positioned(
                        bottom: -13,
                        right: 0,
                        left: 0,
                        child: CirclePageIndicator(
                          selectedSize: 8,
                          selectedDotColor: Const.kWhite.withOpacity(0.7),
                          dotColor: Const.kWhite.withOpacity(0.1),
                          currentPageNotifier: _currentPageNotifier,
                          itemCount: headSongs.length,
                        ),
                      ),
                    ],
                  ),
                  crossFadeState: showHeadMusic
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: Duration(milliseconds: 400),
                )
              : SizedBox(),
          Column(
            children: Const.genres.map((e) {
              return getGenreWidget(e);
            }).toList(),
          ),
          Column(
            children: genres.map((e) {
              return getYoutubeGenreWidget(e);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget getGenreWidget(Genre genre) {
    return StreamBuilder<List<Audio>>(
      stream: context.myData.aB.getAudiosFromGenre(genre.id),
      initialData: [],
      builder: (context, snapshot) {
        List<Audio> audios = snapshot.data ?? [];
        if (audios.isEmpty) {
          return SizedBox();
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8, left: 12),
                child: Text(
                  genre.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              Container(
                height: 140,
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: audios.length,
                  itemBuilder: (c, i) {
                    Audio audio = audios[i];
                    return InkWell(
                      onTap: () {
                        context.push(
                          PlayingScreen(
                            song: audio.toMediaItem,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 124,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  audio.image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: -0.5,
                                right: 0,
                                left: 0,
                                top: 50,
                                child: Container(
                                  padding: EdgeInsets.only(bottom: 3),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(8),
                                    ),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black,
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Text(
                                      audio.title,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Const.kWhite,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget getYoutubeGenreWidget(YoutubeGenre youtubeGenre) {
    if ((youtubeGenre.playlists ?? []).isEmpty) {
      return SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8, left: 12),
          child: Text(
            youtubeGenre.title ?? "",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        Divider(
          height: 2,
          thickness: 2,
          color: Colors.white12,
        ),
        Container(
          height: youtubeGenre.playlists!.first.isPlaylist
              ? 140
              : 124 / 16 * 9 + 16,
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: youtubeGenre.playlists?.length,
            itemBuilder: (c, i) {
              YoutubePlaylist myPlaylist = youtubeGenre.playlists![i];
              return InkWell(
                onTap: () {
                  //? playlist ekranına gidicek
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 124,
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: myPlaylist.isPlaylist ? 1 : 16 / 9,
                          child: Builder(
                            builder: (context) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  myPlaylist.imageQuality(
                                    false,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          bottom: -0.5,
                          right: 0,
                          left: 0,
                          top: myPlaylist.isPlaylist ? 50 : 30,
                          child: Container(
                            padding: EdgeInsets.only(bottom: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(8),
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black,
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Text(
                                myPlaylist.title ?? "",
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Const.kWhite,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
