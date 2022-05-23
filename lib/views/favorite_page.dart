import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/providers/data.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/playing_screen/playing_screen.dart';
import 'package:provider/provider.dart';

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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Favori Müzikler"),
        ),
        body: favorisongs.isNotEmpty
            ? ListView.builder(
                itemCount: favorisongs.length,
                itemBuilder: (BuildContext context, int index) {
                  MediaItem mediItem = favorisongs[index];
                  return Dismissible(
                    key: Key(mediItem.id),
                    onDismissed: (l) {
                      setState(() {
                        favorisongs.removeAt(index);
                        context.myData.removeFavoritedSong(mediItem);
                      });
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      onTap: () {
                        context.push(PlayingScreen(
                          song: mediItem,
                          queue: favorisongs,
                        ));
                      },
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                            width: 75,
                            height: 75,
                            child: mediItem.getImageWidget),
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
      ),
    );
  }
}
