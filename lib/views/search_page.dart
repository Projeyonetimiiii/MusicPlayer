import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:onlinemusic/models/audio.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../services/search_service.dart';
import '../widgets/search_cards.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController searcController = TextEditingController();
  bool findMusic = false;
  bool searchStarted = false;
  List<SongModel> getMusicList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _searchBar(),
      ),
      key: scaffoldKey,
      body: SafeArea(
        child: ListView(
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
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildTitle("Kullanıcıların Yükledikleri Müzikler:"),
                      Column(
                          children: snapshot.data!
                              .map((e) => buildMusicItem(
                                  e.toMediaItem,
                                  snapshot.data!
                                      .map((e) => e.toMediaItem)
                                      .toList(),
                                  context))
                              .toList()),
                    ],
                  );
                } else {
                  return Center(
                    child: CupertinoActivityIndicator(),
                  );
                }
              },
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTitle("Cihazdaki Müzikler:"),
                Column(
                    children: SearchService.fetchMusicFromQuery(
                            searcController.text.toLowerCase(), context)
                        .map((e) => buildMusicItem(
                            e.toMediaItem,
                            SearchService.fetchMusicFromQuery(
                                    searcController.text.toLowerCase(), context)
                                .map((e) => e.toMediaItem)
                                .toList(),
                            context))
                        .toList()),
              ],
            ),
            FutureBuilder<List<Video>>(
              future:
                  SearchService.fetchVideos(searcController.text.toLowerCase()),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Video>> snapshot) {
                if (snapshot.hasData) {
                  if ((snapshot.data ?? []).isEmpty) {
                    return SizedBox();
                  }
                  //youtube
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildTitle("Youtube Müzikleri:"),
                      Column(
                        children: snapshot.data!
                            .map((e) => buildMusicItem(
                                e.toMediaItem,
                                snapshot.data!
                                    .map((e) => e.toMediaItem)
                                    .toList(),
                                context))
                            .toList(),
                      ),
                    ],
                  );
                } else {
                  return Center(
                    child: CupertinoActivityIndicator(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTitle(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicWidth(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Divider(
              color: Colors.black,
              thickness: 1,
              height: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
        child: TextField(
            autofocus: true,
            controller: searcController,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Müzik Bul",
              hintStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).secondaryHeaderColor),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.close,
                  size: 25,
                  color: Theme.of(context).iconTheme.color,
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
            }));
  }
}
