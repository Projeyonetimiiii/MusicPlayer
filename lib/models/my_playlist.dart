// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:onlinemusic/util/converter.dart';
import 'package:onlinemusic/util/extensions.dart';

class MyPlaylist {
  DateTime createdDate;
  String name;
  List<MediaItem> songs;
  MyPlaylist({
    required this.createdDate,
    required this.name,
    required this.songs,
  });

  MyPlaylist copyWith({
    DateTime? createdDate,
    String? name,
    List<MediaItem>? songs,
  }) {
    return MyPlaylist(
      createdDate: createdDate ?? this.createdDate,
      name: name ?? this.name,
      songs: songs ?? this.songs,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'createdDate': createdDate.millisecondsSinceEpoch,
      'name': name,
      'songs': songs.map((x) => x.toJson).toList(),
    };
  }

  factory MyPlaylist.fromMap(Map<String, dynamic> map) {
    return MyPlaylist(
      createdDate: DateTime.fromMillisecondsSinceEpoch(map['createdDate']),
      name: map['name'] as String,
      songs: List<MediaItem>.from(
        (map['songs'] as List<dynamic>).map<MediaItem>(
          (x) => MediaItemConverter.jsonToMediaItem(x),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory MyPlaylist.fromJson(String source) =>
      MyPlaylist.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'MyPlaylist(createdDate: $createdDate, name: $name, songs: $songs)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MyPlaylist &&
        other.createdDate == createdDate &&
        other.name == name &&
        listEquals(other.songs, songs);
  }

  @override
  int get hashCode => createdDate.hashCode ^ name.hashCode ^ songs.hashCode;
}
