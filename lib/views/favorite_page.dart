import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/playing_screen/playing_screen.dart';

class FavoritePage extends StatefulWidget {
  FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<MediaItem> favorisongs = [];

  @override
  void initState() {
    super.initState();
    favorisongs = context.myData.getFavoriteSong();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favori Müziklerim"),
      ),
      body: favorisongs.isNotEmpty
          ? ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: favorisongs.length,
              itemBuilder: (BuildContext context, int index) {
                MediaItem mediItem = favorisongs[index];
                return Dismissible(
                  key: Key(mediItem.id),
                  background: Container(
                    color: Colors.red,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  onDismissed: (l) {
                    setState(() {
                      favorisongs.removeAt(index);
                      context.myData.removeFavoritedSong(mediItem);
                    });
                  },
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    onTap: () {
                      context.pushOpaque(PlayingScreen(
                        song: mediItem,
                        queue: favorisongs,
                      ));
                    },
                    leading: Material(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 90,
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: mediItem.getImageWidget,
                          ),
                        ),
                      ),
                    ),
                    trailing: Text(Const.getDurationString(
                        mediItem.duration ?? Duration.zero)),
                    title: Text(
                      mediItem.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Text("Favori Müziğiniz Yok"),
            ),
    );
  }
}
