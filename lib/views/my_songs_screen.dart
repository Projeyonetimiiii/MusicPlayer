import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/providers/data.dart';
import 'package:onlinemusic/services/search_service.dart';
import 'package:onlinemusic/services/theme_service.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/enums.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/util/helper_functions.dart';
import 'package:onlinemusic/widgets/custom_back_button.dart';
import 'package:onlinemusic/widgets/build_media_items.dart';

import '../widgets/short_popupbutton.dart';

class MySongsScren extends StatefulWidget {
  MySongsScren({Key? key}) : super(key: key);

  @override
  State<MySongsScren> createState() => _MySongsScrenState();
}

class _MySongsScrenState extends State<MySongsScren> {
  late MyData data;
  SortType? sortType;
  OrderType? orderType;

  @override
  void initState() {
    data = context.myData;
    data.addListener(_listener);
    super.initState();
  }

  @override
  void dispose() {
    data.removeListener(_listener);
    super.dispose();
  }

  void _listener() {
    setState(() {});
  }

  int get songsCount {
    return context.myData.songs.value.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<Object>(
            stream: data.songs,
            builder: (context, snapshot) {
              return Text("Müziğim ${songsCount == 0 ? "" : "($songsCount)"}");
            }),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: LocalSearchDelegate());
            },
            icon: Icon(Icons.search_rounded),
          ),
          SortPopupButton(
            changeSort: (sort, order) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                setState(() {
                  sortType = sort;
                  orderType = order;
                });
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<LoadedType>(
        stream: data.loadedType,
        initialData: data.loadedType.value,
        builder: (context, snapshot) {
          if (snapshot.data == LoadedType.None) {
            return SizedBox();
          }
          if (snapshot.data == LoadedType.PermissionDenied) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(child: Text("İzin verilmedi")),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Const.kBackground.withOpacity(0.1),
                    shape: StadiumBorder(),
                  ),
                  onPressed: () {
                    data.getMusics();
                  },
                  child: Text("Yenile"),
                ),
              ],
            );
          }

          if (!snapshot.hasData || snapshot.data == LoadedType.Loading) {
            return Center(
              child: CircularProgressIndicator(
                color: Const.kBackground,
              ),
            );
          }
          return StreamBuilder<List<MediaItem>>(
            stream: data.songs,
            initialData: data.songs.value,
            builder: (c, snap) {
              List<MediaItem> items = data.songs.value;
              if (sortType == null && orderType == null) {
                items = sortItems(items, SortType.Name, OrderType.Growing);
              } else {
                items = sortItems(items, sortType!, orderType!);
              }
              return BuildMediaItems(
                items: items,
                type: BuildMusicListType.Downloaded,
                padding: EdgeInsets.only(
                  bottom: 130,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class LocalSearchDelegate extends SearchDelegate {
  ThemeService service = ThemeService();
  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      scaffoldBackgroundColor: Const.themeColor,
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Const.contrainsColor,
        selectionColor: Const.contrainsColor.withOpacity(0.1),
        selectionHandleColor: Const.contrainsColor,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Const.themeColor,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return CustomBackButton(
      color: Const.kBackground,
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return getMusics(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return getMusics(context);
  }

  Widget getMusics(BuildContext context) {
    List<MediaItem> items =
        SearchService.fetchMusicFromQuery(query.trim().toLowerCase(), context);

    if (items.isEmpty) {
      return Center(
        child: Text("Burada hiçbirşey yok"),
      );
    }

    return BuildMediaItems(
      items: items,
    );
  }
}
