import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:onlinemusic/util/converter.dart';
import 'package:onlinemusic/util/extensions.dart';

class ConnectedController {
  Duration position;
  MediaItem song;
  bool isPlaying;
  bool isReady;
  ConnectedController({
    required this.position,
    required this.song,
    required this.isPlaying,
    required this.isReady,
  });

  ConnectedController copyWith({
    Duration? position,
    MediaItem? song,
    bool? isPlaying,
    bool? isReady,
  }) {
    return ConnectedController(
      position: position ?? this.position,
      song: song ?? this.song,
      isPlaying: isPlaying ?? this.isPlaying,
      isReady: isReady ?? this.isReady,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'position': position.inMilliseconds,
      'song': song.toMap,
      'isPlaying': isPlaying,
      'isReady': isReady,
    };
  }

  factory ConnectedController.fromMap(Map<String, dynamic> map) {
    return ConnectedController(
      position: Duration(milliseconds: map['position'] ?? 0),
      song: MediaItemConverter.mapToMediaItem(
          map['song'] as Map<String, dynamic>),
      isPlaying: map['isPlaying'] as bool,
      isReady: map['isReady'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory ConnectedController.fromJson(String source) =>
      ConnectedController.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Controller(position: $position, song: $song, isPlaying: $isPlaying, isReady: $isReady)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConnectedController &&
        other.position == position &&
        other.song == song &&
        other.isPlaying == isPlaying &&
        other.isReady == isReady;
  }

  @override
  int get hashCode {
    return position.hashCode ^
        song.hashCode ^
        isPlaying.hashCode ^
        isReady.hashCode;
  }
}
