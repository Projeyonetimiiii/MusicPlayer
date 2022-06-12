// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:onlinemusic/util/converter.dart';
import 'package:onlinemusic/util/extensions.dart';

class ConnectedController {
  Duration position;
  MediaItem song;
  List<MediaItem> queue;
  bool isPlaying;
  bool? isReady;
  ConnectedController({
    required this.position,
    required this.song,
    required this.queue,
    required this.isPlaying,
    this.isReady,
  });

  ConnectedController copyWith({
    Duration? position,
    MediaItem? song,
    List<MediaItem>? queue,
    bool? isPlaying,
    bool? isReady,
  }) {
    return ConnectedController(
      position: position ?? this.position,
      song: song ?? this.song,
      queue: queue ?? this.queue,
      isPlaying: isPlaying ?? this.isPlaying,
      isReady: isReady ?? this.isReady,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'position': position.inMilliseconds,
      'song': jsonEncode(song.toMap),
      'queue': queue.map((x) => jsonEncode(x.toMap)).toList(),
      'isPlaying': isPlaying,
      if (isReady != null) 'isReady': isReady,
    };
  }

  factory ConnectedController.fromMap(Map<String, dynamic> map) {
    return ConnectedController(
      position: Duration(milliseconds: map['position']),
      song: MediaItemConverter.mapToMediaItem(
          jsonDecode(map['song']) as Map<String, dynamic>),
      queue: List<MediaItem>.from(
        (map['queue'] as List<dynamic>).map<MediaItem>(
          (x) => MediaItemConverter.mapToMediaItem(
              jsonDecode(x) as Map<String, dynamic>),
        ),
      ),
      isPlaying: map['isPlaying'] as bool,
      isReady: map['isReady'] != null ? map['isReady'] as bool : false,
    );
  }

  String toJson() => json.encode(toMap());

  factory ConnectedController.fromJson(String source) =>
      ConnectedController.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ConnectedController(position: $position, song: $song, queue: $queue, isPlaying: $isPlaying, isReady: $isReady)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConnectedController &&
        other.position == position &&
        other.song == song &&
        listEquals(other.queue, queue) &&
        other.isPlaying == isPlaying &&
        other.isReady == isReady;
  }

  @override
  int get hashCode {
    return position.hashCode ^
        song.hashCode ^
        queue.hashCode ^
        isPlaying.hashCode ^
        isReady.hashCode;
  }
}
