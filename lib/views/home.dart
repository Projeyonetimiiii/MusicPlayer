import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/share_song_screen.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Ana sayfa"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(ShareSongScreen());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
