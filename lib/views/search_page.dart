import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:onlinemusic/models/audio.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/widgets/custom_back_button.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../services/search_service.dart';
import '../widgets/search_cards.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;
  SearchScreen({Key? key, this.initialQuery = ""}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  late final TextEditingController searcController;
  bool findMusic = false;
  bool searchStarted = false;
  List<SongModel> getMusicList = [];

  @override
  void initState() {
    searcController = TextEditingController(text: widget.initialQuery);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: CustomBackButton(
          color: Const.kBackground,
        ),
        backgroundColor: Colors.transparent,
        title: _searchBar(),
      ),
      key: scaffoldKey,
      body: ListView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          top: 16,
        ),
        children: [
          FutureBuilder<List<Audio>>(
            future: SearchService.fetchAudiosFromQuery(
                searcController.text.toLowerCase()),
            builder:
                (BuildContext context, AsyncSnapshot<List<Audio>> snapshot) {
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
                            items: snapshot.data!
                                .map((e) => e.toMediaItem)
                                .toList(),
                            scrollable: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Center(
                  child: CupertinoActivityIndicator(),
                );
              }
            },
          ),
          getLocalSongs(),
          FutureBuilder<List<Video>>(
            future:
                SearchService.fetchVideos(searcController.text.toLowerCase()),
            builder:
                (BuildContext context, AsyncSnapshot<List<Video>> snapshot) {
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
                                items: snapshot.data!
                                    .map((e) => e.toMediaItem)
                                    .toList(),
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
          ),
        ],
      ),
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

  Widget _searchBar() {
    return Container(
      height: 40,
      child: Card(
          color: Const.kBackground,
          elevation: 0,
          shape: StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
            ),
            child: TextField(
                autofocus: true,
                controller: searcController,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                cursorColor: Colors.white,
                cursorRadius: Radius.circular(6),
                cursorWidth: 1,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: "Müzik Ara",
                  hintStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white60,
                  ),
                  suffixIcon: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        searcController.text = "";
                      });
                    },
                  ),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  setState(() {});
                }),
          )),
    );
  }

  Widget getLocalSongs() {
    List<MediaItem> songs = SearchService.fetchMusicFromQuery(
      searcController.text.toLowerCase(),
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
}
