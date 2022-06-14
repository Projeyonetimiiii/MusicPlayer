import 'package:flutter/material.dart';
import 'package:onlinemusic/models/audio.dart';
import 'package:onlinemusic/models/usermodel.dart';
import 'package:onlinemusic/services/audios_bloc.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/widgets/search_cards.dart';

class SharedSongsScreen extends StatefulWidget {
  final UserModel user;
  SharedSongsScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<SharedSongsScreen> createState() => _SharedSongScreenState();
}

class _SharedSongScreenState extends State<SharedSongsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.userName ?? "User"),
      ),
      body: getBody(),
    );
  }

  Widget getBody() {
    List<Audio> audios = AudiosBloc()
        .audioList
        .where((element) => element.idOfTheSharingUser == widget.user.id)
        .toList();
    Widget? child;
    if (audios.isEmpty) {
      child = Center(
        child: Text("Hiç Müzik Yok!"),
      );
    } else {
      child = BuildMediaItems(items: audios.map((e) => e.toMediaItem).toList());
    }
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 350),
      child: child,
    );
  }
}
