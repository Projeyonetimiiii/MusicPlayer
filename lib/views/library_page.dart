import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/providers/data.dart';
import 'package:onlinemusic/services/search_service.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/widgets/custom_back_button.dart';
import 'package:onlinemusic/widgets/build_media_items.dart';

class LibraryPage extends StatefulWidget {
  LibraryPage({Key? key}) : super(key: key);

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late MyData data;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cihaz"),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: LocalSearchDelegate());
            },
            icon: Icon(Icons.search_rounded),
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

          return BuildMediaItems(
            items: data.songs,
            padding: EdgeInsets.only(
              bottom: 130,
            ),
          );
        },
      ),
    );
  }
}

class LocalSearchDelegate extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: Colors.grey.shade200,
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Const.kBackground,
        selectionColor: Const.kBackground.withOpacity(0.1),
        selectionHandleColor: Const.kBackground,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.grey.shade200,
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
