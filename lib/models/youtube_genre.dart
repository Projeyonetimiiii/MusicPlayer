import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:onlinemusic/models/youtube_playlist.dart';

class YoutubeGenre {
  String? title;
  List<YoutubePlaylist>? playlists;
  YoutubeGenre({
    this.title,
    this.playlists,
  }) : super();

  YoutubeGenre copyWith({
    String? title,
    List<YoutubePlaylist>? playlists,
  }) {
    return YoutubeGenre(
      title: title ?? this.title,
      playlists: playlists ?? this.playlists,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'playlists': playlists?.map((x) => x.toMap()).toList(),
    };
  }

  factory YoutubeGenre.fromMap(Map<String, dynamic> map) {
    return YoutubeGenre(
      title: map['title'],
      playlists: List<YoutubePlaylist>.from(
          map['playlists']?.map((x) => YoutubePlaylist.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory YoutubeGenre.fromJson(String source) =>
      YoutubeGenre.fromMap(json.decode(source));

  @override
  String toString() => 'PlaylistModel(title: $title, playlists: $playlists)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is YoutubeGenre &&
        other.title == title &&
        listEquals(other.playlists, playlists);
  }

  @override
  int get hashCode => title.hashCode ^ playlists.hashCode;
}
