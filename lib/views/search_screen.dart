import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/models/audio.dart';
import 'package:onlinemusic/providers/data.dart';
import 'package:onlinemusic/services/search_service.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/widgets/search_cards.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchScreen({Key? key, this.initialQuery}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  YoutubeExplode youtubeExplode = YoutubeExplode();
  late final FloatingSearchBarController _controller;
  late MyData data;

  @override
  void initState() {
    super.initState();
    data = context.myData;
    data.addListener(_listener);
    _controller = FloatingSearchBarController();
    _controller.query = widget.initialQuery ?? "";
  }

  void _listener() {
    setState(() {});
  }

  @override
  void dispose() {
    data.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(child: searchPageBody()),
    );
  }

  searchPageBody() {
    return FloatingSearchBar(
      backgroundColor: Colors.white,
      accentColor: Const.kBackground,
      shadowColor: Colors.black54,
      openAxisAlignment: 0,
      insets: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      elevation: 4,
      transition: CircularFloatingSearchBarTransition(),
      automaticallyImplyBackButton: false,
      automaticallyImplyDrawerHamburger: false,
      borderRadius: BorderRadius.circular(10.0),
      controller: _controller,
      leadingActions: [
        FloatingSearchBarAction.icon(
          showIfOpened: true,
          size: 20.0,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onTap: () {
            if (_controller.isOpen)
              _controller.close();
            else {
              Navigator.pop(context);
            }
          },
        ),
      ],
      hint: "Ara",
      height: 45.0,
      physics: BouncingScrollPhysics(),
      transitionCurve: Curves.easeInOut,
      margins: const EdgeInsets.fromLTRB(16, 8.0, 16, 15.0),
      clearQueryOnClose: false,
      debounceDelay: const Duration(milliseconds: 500),
      onSubmitted: (c) {
        _controller.close();
        List<String> history = getHistory;
        setState(() {});
        if (!history.any((element) => element == c)) {
          history.add(c);
          cacheBox!.put("searchHistory", history);
        }
      },
      builder: (c, i) {
        return StreamBuilder<BoxEvent>(
            stream: cacheBox!.watch(key: "searchHistory"),
            builder: (context, state) {
              List<String> history = getHistory;
              if (history.isEmpty) return SizedBox();
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: Const.kBackground,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: history
                        .map(
                          (e) => ListTile(
                            dense: true,
                            title: Text(
                              e,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              _controller.close();
                              setState(() {
                                _controller.query = e;
                              });
                            },
                            trailing: IconButton(
                              onPressed: () {
                                history.remove(e);
                                cacheBox!.put("searchHistory", history);
                              },
                              icon: Icon(
                                Icons.clear_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              );
            });
      },
      body: ListView(
        padding: EdgeInsets.only(top: 50),
        physics: BouncingScrollPhysics(),
        children: [
          getLocalSongs(),
          getFirebaseSongs(),
          getYoutubeSongs(),
        ],
      ),
    );
  }

  List<String> get getHistory {
    return (cacheBox!.get("searchHistory", defaultValue: []) as List)
        .map((e) => e.toString())
        .toList();
  }

  Widget getFirebaseSongs() {
    return FutureBuilder<List<Audio>>(
      future:
          SearchService.fetchAudiosFromQuery(_controller.query.toLowerCase()),
      builder: (BuildContext context, AsyncSnapshot<List<Audio>> snapshot) {
        if (snapshot.hasData) {
          if ((snapshot.data ?? []).isEmpty) {
            return SizedBox();
          }
          //firebase
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTitle("Kullanıcı Müzikleri"),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    elevation: 6,
                    color: Colors.white,
                    child: BuildMediaItems(
                      items: snapshot.data!.map((e) => e.toMediaItem).toList(),
                      scrollable: false,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Const.kBackground,
            ),
          );
        }
      },
    );
  }

  Widget getYoutubeSongs() {
    return FutureBuilder<List<Video>>(
      future: SearchService.fetchVideos(_controller.query.toLowerCase()),
      builder: (BuildContext context, AsyncSnapshot<List<Video>> snapshot) {
        Widget? child;
        if (snapshot.hasData) {
          if ((snapshot.data ?? []).isEmpty) {
            child = SizedBox();
          } else {
            //youtube
            child = Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTitle("Youtube Müzik"),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      elevation: 6,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                        ),
                        child: BuildMediaItems(
                          items:
                              snapshot.data!.map((e) => e.toMediaItem).toList(),
                          scrollable: false,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        } else {
          child = SizedBox();
        }
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 350),
          child: child,
        );
      },
    );
  }

  Widget getLocalSongs() {
    List<MediaItem> songs = SearchService.fetchMusicFromQuery(
      _controller.query.toLowerCase(),
      context,
    );
    Widget? child;
    if (songs.isEmpty) {
      child = SizedBox();
    } else {
      child = Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTitle("Cihazdaki Müzikler"),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                elevation: 6,
                color: Colors.white,
                child: BuildMediaItems(
                  items: songs,
                  scrollable: false,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 350),
      child: child,
    );
  }

  Widget buildTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Const.kBackground,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(6),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: IntrinsicWidth(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
