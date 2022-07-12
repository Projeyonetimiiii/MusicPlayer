import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlinemusic/models/my_playlist.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SearchService {
  static List<MediaItem> fetchMusicFromQuery(
      String query, BuildContext context) {
//cihaz daki müzikleri ara
    List<MediaItem> songs = [];
    if (query.isEmpty) {
      return context.myData.songs.value;
    }
    for (MediaItem i in context.myData.songs.value) {
      if ((i.title + (i.artist ?? "")).toLowerCase().contains(query)) {
        songs.add(i);
      }
    }

    return songs;
  }

  static Future<VideoSearchList?> fetchVideos(String query) async {
    if (query.isEmpty) {
      return null;
    }
    final YoutubeExplode yt = YoutubeExplode();

    final VideoSearchList searchResults = await yt.search.search(query);
    searchResults.nextPage();
    searchResults.removeWhere((element) => element.isLive);

    return searchResults;
  }

  static Future<MyPlaylist?> getMyPlaylistFromUrl(String inLink) async {
    final YoutubeExplode yt = YoutubeExplode();
    final String link = '$inLink&';
    try {
      final RegExpMatch? id = RegExp(r'.*list\=(.*?)&').firstMatch(link);
      if (id != null) {
        final Playlist metadata = await yt.playlists.get(id[1]!);
        final List<Video> songs = await yt.playlists.getVideos(id[1]!).toList();
        return MyPlaylist(
          createdDate: DateTime.now(),
          name: metadata.title,
          songs: songs.map((e) => e.toMediaItem).toList(),
        );
      }
      return Future.error("Oynatma listesi alınırken hata oluştu");
    } catch (e) {
      return Future.error("Oynatma listesi alınırken hata oluştu");
    }
  }
}
