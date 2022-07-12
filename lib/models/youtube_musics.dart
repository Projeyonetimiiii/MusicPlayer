import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:onlinemusic/models/head_music.dart';
import 'package:onlinemusic/models/youtube_genre.dart';

class YoutubeMusics {
  List<YoutubeGenre>? genres;
  List<HeadMusic>? headSongs;
  YoutubeMusics({
    this.genres,
    this.headSongs,
  });

  YoutubeMusics copyWith({
    List<YoutubeGenre>? playlists,
    List<HeadMusic>? headMusics,
  }) {
    return YoutubeMusics(
      genres: playlists ?? this.genres,
      headSongs: headMusics ?? this.headSongs,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'genres': genres?.map((x) => x.toMap()).toList(),
      'headMusics': headSongs?.map((x) => x.toMap()).toList(),
    };
  }

  factory YoutubeMusics.fromMap(Map<String, dynamic> map) {
    return YoutubeMusics(
      genres: map['genres'] != null
          ? List<YoutubeGenre>.from(map['genres']
              ?.map((x) => YoutubeGenre.fromMap(Map<String, dynamic>.from(x))))
          : null,
      headSongs: map['headMusics'] != null
          ? List<HeadMusic>.from(map['headMusics']
              ?.map((x) => HeadMusic.fromMap(Map<String, dynamic>.from(x))))
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory YoutubeMusics.fromJson(String source) =>
      YoutubeMusics.fromMap(json.decode(source));

  @override
  String toString() =>
      'MusicsModel(playlists: $genres, headMusics: $headSongs)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is YoutubeMusics &&
        listEquals(other.genres, genres) &&
        listEquals(other.headSongs, headSongs);
  }

  @override
  int get hashCode => genres.hashCode ^ headSongs.hashCode;
}
