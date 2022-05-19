import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:onlinemusic/util/extensions.dart';

class BackgroundAudioHandler extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  final AudioPlayer player = AudioPlayer();
  int index = -1;
  bool get isPlaying => player.playing;
  Duration get position => player.position;

  Stream<bool> get playingStream => player.playingStream;
  Stream<Duration> get positionStream => player.positionStream;

  BackgroundAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    player.playbackEventStream.listen((s) {
      _broadcastState();
    });
    player.positionStream.listen((event) {
      _broadcastState();
    });
  }

  void _broadcastState() {
    final playing = player.playing;
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[player.processingState]!,
      playing: playing,
      updatePosition: player.position,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
      queueIndex: index,
    ));
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem1) async {
    updateMediaItemIndex(mediaItem1);
    await updatePlayingMediaItem(mediaItem1);
  }

  @override
  Future<void> play() async {
    try {
      await player.play();
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Future<void> pause() => player.pause();

  void updateMediaItemIndex(MediaItem mediaItem1) {
    if (queue.value.any((e) => e.id == mediaItem1.id)) {
      index = queue.value.indexWhere((e) => e.id == mediaItem1.id);
    }
  }

  Future<void> updatePlayingMediaItem(MediaItem mediaItem1) async {
    mediaItem.add(mediaItem1);
    String? url = mediaItem1.extras?["url"];

    if (!mediaItem1.isHaveUrl) {
      player.seek(Duration.zero);
      player.stop();
      url = await mediaItem1.source;
    }
    if (url == null) return;
    if (mediaItem1.isOnline) {
      try {
        await player.setAudioSource(
          ProgressiveAudioSource(Uri.parse(url), duration: mediaItem1.duration),
        );
      } on Exception catch (e) {
        debugPrint(e.toString());
      }
    } else {
      try {
        await player.setFilePath(url);
      } on Exception catch (_) {
        player.stop();
      }
    }
  }

  @override
  Future<void> stop() async {
    await pause();
    mediaItem.add(null);
    return super.stop();
  }
}
