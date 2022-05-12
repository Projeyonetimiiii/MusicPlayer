import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:onlinemusic/views/category_sheet.dart';
import 'package:provider/provider.dart';

import '../providers/data.dart';

class ShareSongPage extends StatefulWidget {
  ShareSongPage({Key? key}) : super(key: key);

  @override
  State<ShareSongPage> createState() => _ShareSongPageState();
}

class _ShareSongPageState extends State<ShareSongPage> {
  @override
  Widget build(BuildContext context) {
    final musicData = Provider.of<MyData>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Müzik Paylaş"),
      ),
      body: musicData.songs.isEmpty
          ? Center(
              child: CupertinoActivityIndicator(),
            )
          : ListView.builder(
              itemCount: musicData.songs.length,
              itemBuilder: (context, int index) {
                SongModel music = musicData.songs[index];
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 5.0,
                  ),
                  child: ListTile(
                    leading: Container(
                      height: 50.0,
                      width: 50.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        //  image: DecorationImage(image:  FileImage())
                      ),
                      clipBehavior: Clip.antiAlias,
                    ),
                    title: Text(
                      music.title.toString(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      music.artist.toString(),
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () async {
                      await showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return CategoryPage();
                          });
                    },
                  ),
                );
              }),
    );
  }
}
