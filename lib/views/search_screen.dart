import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/services/download_service.dart';
import 'package:onlinemusic/services/search_service.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/widgets/mini_player.dart';
import 'package:onlinemusic/widgets/build_media_items.dart';
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
  ValueNotifier<bool> isLoading = ValueNotifier(true);
  VideoSearchList? videoSearchList;
  List<Video> searchedList = [];
  late String lastQuery;

  @override
  void initState() {
    super.initState();
    saveInitialQuery();
    _controller = FloatingSearchBarController();
    lastQuery = widget.initialQuery ?? "";
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _controller.query = widget.initialQuery ?? "";
      VideoSearchList? list = await SearchService.fetchVideos(
          _controller.query.toLowerCase().trim());
      videoSearchList = list;
      if (list != null) searchedList.addAll(list);
      loaded();
      setState(() {});
    });
  }

  saveInitialQuery() {
    if ((widget.initialQuery ?? "").trim().isNotEmpty) {
      List<String> history = getHistory;
      if (!history.any((element) => element == widget.initialQuery)) {
        history.add(widget.initialQuery!);
        cacheBox!.put("searchHistory", history);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: searchPageBody()),
            MiniPlayer(),
          ],
        ),
      ),
    );
  }

  searchPageBody() {
    return FloatingSearchBar(
      backgroundColor: Const.themeColor.withOpacity(0.2),
      accentColor: Const.contrainsColor,
      shadowColor: Const.themeColor,
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
      onSubmitted: (c) async {
        _controller.close();
        List<String> history = getHistory;
        isLoading.value = true;
        videoSearchList = null;
        if (c.toLowerCase().trim() != lastQuery) {
          searchedList.clear();
          lastQuery = c.toLowerCase().trim();
        }
        VideoSearchList? list =
            await SearchService.fetchVideos(c.toLowerCase().trim());
        videoSearchList = list;
        if (list != null) searchedList.addAll(list);
        loaded();
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
      body: Stack(
        children: [
          ValueListenableBuilder<bool>(
              valueListenable: isLoading,
              builder: (context, value, snapshot) {
                return Positioned(
                  top: 53.5,
                  right: 23,
                  left: 23,
                  child: value
                      ? LinearProgressIndicator(
                          minHeight: 3,
                          backgroundColor:
                              Const.contrainsColor.withOpacity(0.1),
                          color: Const.contrainsColor.withOpacity(0.5),
                        )
                      : SizedBox(),
                );
              }),
          ListView(
            padding: EdgeInsets.only(top: 50),
            physics: BouncingScrollPhysics(),
            children: [
              getYoutubeSongs(),
            ],
          ),
        ],
      ),
    );
  }

  List<String> get getHistory {
    return (cacheBox!.get("searchHistory", defaultValue: []) as List)
        .map((e) => e.toString())
        .toList();
  }

  void loaded() {
    Future.delayed(Duration(seconds: 3), () {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        isLoading.value = false;
      });
    });
  }

  Widget getYoutubeSongs() {
    Widget? child;

    if (videoSearchList != null) {
      if (searchedList.isEmpty) {
        child = Container(
          height: MediaQuery.of(context).size.height - 50,
          width: double.maxFinite,
          child: Center(child: Text("Burada Hiçbirşey Yok")),
        );
      } else {
        //youtube
        child = Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildTitle("Youtube Müzik (${searchedList.length})"),
                  Spacer(),
                  InkWell(
                    onTap: () async {
                      downloadService.addAllQueue(
                        searchedList.map((e) => e.toMediaItem).toList(),
                        context,
                        isTest: true,
                        showMsg: true,
                      );
                    },
                    child: Icon(Icons.download_rounded),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: isLoading,
                    builder: (context, value, snapshot) {
                      Widget child = Padding(
                        key: ValueKey(value),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AnimatedOpacity(
                          duration: Duration(seconds: 1),
                          opacity: value ? 0.6 : 1,
                          child: InkWell(
                            onTap: value
                                ? null
                                : () async {
                                    isLoading.value = true;
                                    VideoSearchList? list =
                                        await videoSearchList!.nextPage();
                                    videoSearchList = list;
                                    if (list != null) searchedList.addAll(list);
                                    loaded();
                                    setState(() {});
                                  },
                            child: Icon(Icons.search_rounded),
                          ),
                        ),
                      );
                      return child;
                    },
                  ),
                ],
              ),
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
                  elevation: 0,
                  color: Const.contrainsColor.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                    ),
                    child: BuildMediaItems(
                      items: searchedList.map((e) => e.toMediaItem).toList(),
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
      child = SizedBox(
        key: ValueKey("unload"),
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
          color: Const.contrainsColor.withOpacity(0.1),
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
                color: Const.contrainsColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
