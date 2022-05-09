import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:onlinemusic/models/head_music.dart';
import 'package:onlinemusic/models/youtube_genre.dart';

class YoutubeMusics {
  List<YoutubeGenre>? genres;
  List<HeadMusic>? headMusics;
  YoutubeMusics({
    this.genres,
    this.headMusics,
  });

  YoutubeMusics copyWith({
    List<YoutubeGenre>? playlists,
    List<HeadMusic>? headMusics,
  }) {
    return YoutubeMusics(
      genres: playlists ?? this.genres,
      headMusics: headMusics ?? this.headMusics,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'playlists': genres?.map((x) => x.toMap()).toList(),
      'headMusics': headMusics?.map((x) => x.toMap()).toList(),
    };
  }

  factory YoutubeMusics.fromMap(Map<String, dynamic> map) {
    return YoutubeMusics(
      genres: map['genres'] != null
          ? List<YoutubeGenre>.from(map['genres']
              ?.map((x) => YoutubeGenre.fromMap(Map<String, dynamic>.from(x))))
          : null,
      headMusics: map['headMusics'] != null
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
      'MusicsModel(playlists: $genres, headMusics: $headMusics)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is YoutubeMusics &&
        listEquals(other.genres, genres) &&
        listEquals(other.headMusics, headMusics);
  }

  @override
  int get hashCode => genres.hashCode ^ headMusics.hashCode;
}
