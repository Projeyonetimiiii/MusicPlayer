import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/providers/data.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/playing_screen/playing_screen.dart';

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
      ),
      body: ListView.builder(
          padding: EdgeInsets.only(
            bottom: 130,
          ),
          physics: BouncingScrollPhysics(),
          itemCount: data.songs.length,
          itemBuilder: (context, int index) {
            MediaItem music = data.songs[index];
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
                  child: music.getImageWidget,
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
                  context.pushOpaque(
                    PlayingScreen(
                      song: music,
                      queue: data.songs,
                    ),
                  );
                },
              ),
            );
          }),
    );
  }
}
