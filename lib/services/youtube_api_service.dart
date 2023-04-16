import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:onlinemusic/util/helper_functions.dart';

class YoutubeApiService {
  static YoutubeApiService? _instance;

  AutoRefreshingAuthClient? _client;
  Future<bool> initialize() async {
    try {
      final jsonString = await loadJsonFromAssets('json/youtube-api.json');
      final json = jsonDecode(jsonString);
      final _credentials = ServiceAccountCredentials.fromJson(json);
      _client = await clientViaServiceAccount(
          _credentials, [YouTubeApi.youtubeReadonlyScope]);
      return true;
    } catch (ext) {
      print(ext);
      return false;
    }
  }

  Future<List<Video>?> getVideos(String query) async {
    final _response = await YouTubeApi(_client!)
        .videos
        .list(["snippet"], maxResults: 20, chart: "mostPopular");
    final _videos = _response.items;
    return _videos;
  }

  Future<List<PlaylistItem>?> getPlaylistItems(String id) async {
    final _response = await YouTubeApi(_client!)
        .playlistItems
        .list(["snippet"], maxResults: 100, playlistId: id);
    final _playlists = _response.items;
    return _playlists;
  }

  YoutubeApiService._() {
    initialize().then((value) {
      if (value) {
        debugPrint("YoutubeApi Initialized");
      } else {
        debugPrint("YoutubeApi Not Initialized");
      }
    });
  }
  factory YoutubeApiService() {
    return _instance ??= new YoutubeApiService._();
  }
}
