import 'package:flutter/material.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/downloaded_screen.dart';
import 'package:onlinemusic/views/favorite_page.dart';
import 'package:onlinemusic/views/playlist_screen/playlists_screen.dart';

class LibraryScreen extends StatefulWidget {
  LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kütüphane"),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          ListTile(
            leading: Icon(
              Icons.favorite,
            ),
            title: Text("Favori Müziklerim"),
            onTap: () {
              context.push(FavoritePage());
            },
          ),
          ListTile(
            leading: Icon(
              Icons.playlist_play_rounded,
            ),
            title: Text("Oynatma Listelerim"),
            onTap: () {
              context.push(PlaylistsScreen());
            },
          ),
          ListTile(
            leading: Icon(
              Icons.download_done_rounded,
            ),
            title: Text("İndirilenler"),
            onTap: () {
              context.push(DonwnloadedScreen());
            },
          ),
          // Opacity(
          //   opacity: 0.6,
          //   child: ListTile(
          //     leading: Icon(
          //       Icons.history_rounded,
          //     ),
          //     title: Text("Son Oynatılanlar"),
          //   ),
          // ),
          // Opacity(
          //   opacity: 0.6,
          //   child: ListTile(
          //     leading: Icon(
          //       Icons.settings_rounded,
          //     ),
          //     title: Text("Ayarlar"),
          //   ),
          // ),
        ],
      ),
    );
  }
}
