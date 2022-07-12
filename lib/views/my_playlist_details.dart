import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/models/my_playlist.dart';
import 'package:onlinemusic/services/download_service.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/util/helper_functions.dart';
import 'package:onlinemusic/util/mixins.dart';
import 'package:onlinemusic/widgets/custom_back_button.dart';
import 'package:onlinemusic/widgets/mini_player.dart';
import 'package:onlinemusic/widgets/short_popupbutton.dart';

class MyPlaylistDetails extends StatefulWidget {
  final MyPlaylist playlist;
  MyPlaylistDetails({
    Key? key,
    required this.playlist,
  }) : super(key: key);

  @override
  State<MyPlaylistDetails> createState() => _MyPlaylistDetailsState();
}

class _MyPlaylistDetailsState extends State<MyPlaylistDetails>
    with BuildMediaItemMixin {
  bool get isOnline {
    return widget.playlist.songs.any((element) => element.isOnline);
  }

  SortType? sortType;
  OrderType? orderType;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: CustomBackButton(),
        title: Text(widget.playlist.name),
        actions: [
          if (isOnline)
            IconButton(
              tooltip: "Hepsini indir",
              onPressed: () {
                downloadService.addAllQueue(
                  widget.playlist.songs,
                  context,
                  isTest: true,
                );
              },
              icon: Icon(
                Icons.download_rounded,
                color: Const.contrainsColor,
              ),
            ),
          SortPopupButton(
            changeSort: (sort, order) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                setState(() {
                  sortType = sort;
                  orderType = order;
                });
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.playlist.songs.isEmpty
                ? Center(
                    child: Text("Burada hiç müzik yok"),
                  )
                : getBody(),
          ),
          MiniPlayer(),
        ],
      ),
    );
  }

  Widget getBody() {
    List<MediaItem> items = widget.playlist.songs;
    if (sortType == null && orderType == null) {
      items = sortItems(items, SortType.Name, OrderType.Growing);
    } else {
      items = sortItems(items, sortType!, orderType!);
    }
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (c, i) {
        return Dismissible(
          key: ValueKey(i),
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
          onDismissed: (s) {
            context.myData.updatePlaylist(
              widget.playlist.copyWith(
                songs: widget.playlist.songs..removeAt(i),
              ),
            );
          },
          direction: DismissDirection.horizontal,
          child: buildMusicItem(items[i], items),
        );
      },
    );
  }
}
