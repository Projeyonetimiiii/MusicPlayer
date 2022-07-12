import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/util/helper_functions.dart';
import 'package:onlinemusic/util/mixins.dart';
import 'package:onlinemusic/widgets/custom_back_button.dart';
import 'package:onlinemusic/widgets/mini_player.dart';
import 'package:onlinemusic/widgets/short_popupbutton.dart';

class FavoritePage extends StatefulWidget {
  FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> with BuildMediaItemMixin {
  SortType? sortType;
  OrderType? orderType;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        title: Text("Favori Müziklerim"),
        actions: [
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
            child: StreamBuilder<List<MediaItem>>(
              stream: context.myData.favoriteSongs,
              initialData: context.myData.favoriteSongs.value,
              builder: (c, snapshot) {
                List<MediaItem> items = snapshot.data!;

                if (items.isEmpty) {
                  return Center(
                    child: Text("Favori Müziğiniz Yok"),
                  );
                }
                if (sortType == null && orderType == null) {
                  items = sortItems(items, SortType.Name, OrderType.Growing);
                } else {
                  items = sortItems(items, sortType!, orderType!);
                }
                return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    MediaItem mediItem = items[index];
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
                            context.myData.removeFavoritedSong(mediItem);
                          });
                        },
                        child: buildMusicItem(mediItem, items));
                  },
                );
              },
            ),
          ),
          MiniPlayer(),
        ],
      ),
    );
  }
}
