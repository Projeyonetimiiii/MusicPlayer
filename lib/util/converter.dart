import 'dart:convert';

import 'package:audio_service/audio_service.dart';

class MediaItemConverter {
  static MediaItem mapToMediaItem(Map<String, dynamic> map) {
    return MediaItem(
      id: map["id"],
      title: map["title"],
      duration: Duration(milliseconds: map["duration"]),
      album: map["album"],
      artist: map["artist"],
      genre: map["genre"],
      artUri: Uri.parse(map["artUri"]),
      extras: map["extras"],
    );
  }

  static MediaItem jsonToMediaItem(String json) {
    return mapToMediaItem(jsonDecode(json));
  }
}
