import 'dart:convert';

import 'package:flutter/foundation.dart';

class Audio {
  String id;
  String title;
  String artist;
  String url;
  String image;
  List<int> genreIds;
  Duration duration;
  String idOfTheSharingUser;
  Audio({
    required this.id,
    required this.title,
    required this.artist,
    required this.url,
    required this.image,
    required this.genreIds,
    required this.duration,
    required this.idOfTheSharingUser,
  });

  Audio copyWith({
    String? id,
    String? title,
    String? artist,
    String? url,
    String? image,
    List<int>? genres,
    Duration? duration,
    String? idOfTheSharingUser,
  }) {
    return Audio(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      url: url ?? this.url,
      image: image ?? this.image,
      genreIds: genres ?? this.genreIds,
      duration: duration ?? this.duration,
      idOfTheSharingUser: idOfTheSharingUser ?? this.idOfTheSharingUser,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'url': url,
      'image': image,
      'genres': genreIds,
      'duration': duration.inMilliseconds,
      'idOfTheSharingUser': idOfTheSharingUser,
    };
  }

  factory Audio.fromMap(Map<String, dynamic> map) {
    return Audio(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      url: map['url'] ?? '',
      image: map['image'] ?? '',
      genreIds: List<int>.from(map['genres']),
      duration: Duration(milliseconds: map['duration']),
      idOfTheSharingUser: map['idOfTheSharingUser'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Audio.fromJson(String source) => Audio.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Audio(id: $id, title: $title, artist: $artist, url: $url, image: $image, genres: $genreIds, duration: $duration, idOfTheSharingUser: $idOfTheSharingUser)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Audio &&
        other.id == id &&
        other.title == title &&
        other.artist == artist &&
        other.url == url &&
        other.image == image &&
        listEquals(other.genreIds, genreIds) &&
        other.duration == duration &&
        other.idOfTheSharingUser == idOfTheSharingUser;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        artist.hashCode ^
        url.hashCode ^
        image.hashCode ^
        genreIds.hashCode ^
        duration.hashCode ^
        idOfTheSharingUser.hashCode;
  }
}
