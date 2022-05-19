import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:onlinemusic/providers/data.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/playing_screen/playing_screen.dart';

class LibraryPage extends StatefulWidget {
  LibraryPage({Key? key}) : super(key: key);

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    MyData data = context.myData;
    return Scaffold(
      appBar: AppBar(
        title: Text("Cihaz"),
      ),
      body: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: data.songs.length,
          itemBuilder: (context, int index) {
            SongModel music = data.songs[index];
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
                    color: Colors.grey.shade300,
                  ),
                  child: FutureBuilder<Uint8List?>(
                    future: OnAudioQuery.platform
                        .queryArtwork(music.id, ArtworkType.AUDIO),
                    builder: (c, snap) {
                      if (!snap.hasData) {
                        return Icon(Icons.hide_image_rounded);
                      } else {
                        return Image.memory(
                          snap.data!,
                          fit: BoxFit.cover,
                        );
                      }
                    },
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
                  context.push(
                    PlayingScreen(song: music.toMediaItem),
                  );
                },
              ),
            );
          }),
    );
  }
}
