import 'package:flutter/material.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/favorite_page.dart';
import 'package:onlinemusic/views/home_page.dart';
import 'package:onlinemusic/views/library_page.dart';
import 'package:onlinemusic/views/search_page.dart';
import 'package:onlinemusic/views/share_song_screen.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class RootApp extends StatefulWidget {
  RootApp({Key? key}) : super(key: key);

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  PageController _pageController = PageController();
  final _bottomPageNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (s) {
          _bottomPageNotifier.value = s;
        },
        children: [
          HomePage(),
          FavoritePage(),
          SearchPage(),
          LibraryPage(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(ShareSongScreen());
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
          valueListenable: _bottomPageNotifier,
          builder: (context, v, snapshot) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: SalomonBottomBar(
                itemPadding: EdgeInsets.symmetric(vertical: 7, horizontal: 20),
                currentIndex: v,
                onTap: (i) {
                  _pageController.jumpToPage(i);
                },
                items: [
                  SalomonBottomBarItem(
                    selectedColor: Const.kWhite,
                    unselectedColor: Const.kWhite.withOpacity(0.6),
                    title: Text("Ana Sayfa"),
                    icon: Icon(Icons.audiotrack_rounded),
                  ),
                  SalomonBottomBarItem(
                    selectedColor: Const.kWhite,
                    unselectedColor: Const.kWhite.withOpacity(0.6),
                    title: Text("Favoriler"),
                    icon: Icon(Icons.favorite),
                  ),
                  SalomonBottomBarItem(
                    selectedColor: Const.kWhite,
                    unselectedColor: Const.kWhite.withOpacity(0.6),
                    title: Text("Ara"),
                    icon: Icon(Icons.search_outlined),
                  ),
                  SalomonBottomBarItem(
                    selectedColor: Const.kWhite,
                    unselectedColor: Const.kWhite.withOpacity(0.6),
                    title: Text("Cihaz"),
                    icon: Icon(Icons.library_music_rounded),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
