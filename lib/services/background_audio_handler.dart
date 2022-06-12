import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/services/auth.dart';
import 'package:onlinemusic/services/connected_song_service.dart';
import 'package:onlinemusic/services/listening_song_service.dart';
import 'package:onlinemusic/services/user_status_service.dart';
import 'package:onlinemusic/util/enums.dart';
import 'package:onlinemusic/util/extensions.dart';

class BackgroundAudioHandler extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  final AudioPlayer player = AudioPlayer();
  int index = -1;
  List<MediaItem> _effectiveQueue = [];
  UserStatusService userStatusService = UserStatusService();
  Timer? _sleepTimer;

  bool get isPlaying => player.playing;
  Duration get position => player.position;

  Stream<bool> get playingStream => player.playingStream;
  Stream<Duration> get positionStream => player.positionStream;

  AudioServiceRepeatMode get repeatMode => playbackState.value.repeatMode;
  AudioServiceShuffleMode get shuffleMode => playbackState.value.shuffleMode;
  BackgroundAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    player.playbackEventStream.listen((s) {
      _broadcastState();
    });
    player.processingStateStream.listen((event) async {
      if (event == ProcessingState.completed) {
        skipItem();
      }
    });
  }

  void skipItem({int skip = 1}) async {
    if (!connectedSongService.isAdmin) {
      return;
    }
    if (connectedSongService.controller.value != null) {
      if (!(connectedSongService.controller.value!.isReady ?? false)) {
        return;
      }
    }
    if (repeatMode == AudioServiceRepeatMode.one) {
      await player.seek(Duration.zero);
      player.play();
    } else if (repeatMode == AudioServiceRepeatMode.all) {
      int newIndex = index + skip;
      if (newIndex < 0) {
        index = queue.value.length;
      } else if (newIndex > queue.value.length - 1) {
        index = 0;
      } else {
        index = newIndex;
      }

      skipToQueueItem(index);
    } else {
      int newIndex = index + skip;
      if (newIndex >= 0 && newIndex < queue.value.length - 1) {
        skipToQueueItem(newIndex);
      } else {
        await player.seek(Duration.zero);
        await player.pause();
      }
    }
  }

  @override
  Future<void> updateQueue(List<MediaItem> newQueue) {
    _effectiveQueue.clear();
    _effectiveQueue.addAll(newQueue);
    return super.updateQueue(newQueue);
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

  @override
  Future<void> seek(Duration position) async {
    if (connectedSongService.isAdmin) {
      player.seek(position);
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
        listeningSongService.listeningSong(mediaItem1);
        if (AuthService().currentUser.value?.connectedUserId == null) {
          userStatusService.updateConenctionType(ConnectionType.Ready);
        }
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
  Future customAction(String name, [Map<String, dynamic>? extras]) {
    if (name == 'sleepTimer') {
      _sleepTimer?.cancel();
      if (extras?['time'] != null &&
          extras!['time'].runtimeType == int &&
          extras['time'] > 0 as bool) {
        _sleepTimer = Timer(Duration(minutes: extras['time'] as int), () {
          stop();
        });
      }
    }

    return super.customAction(name, extras);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < queue.value.length && index > -1) {
      await playMediaItem(queue.value[index]);
      print("userID: " +
          (AuthService().currentUser.value?.id ?? "") +
          "\nisAdmin: " +
          connectedSongService.isAdmin.toString() +
          "\nisConencted: " +
          connectedSongService.isConnectedSong.toString() +
          "   backgroundAudiohandler skipToQueueItem()");
      if (!connectedSongService.isConnectedSong) {
        play();
      }
    }
    return super.skipToQueueItem(index);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    _broadcastState(repeatMode: repeatMode);
  }

  bool get hasPrev {
    if (repeatMode == AudioServiceRepeatMode.none) {
      return index > 0;
    } else {
      return true;
    }
  }

  bool get hasNext {
    if (repeatMode == AudioServiceRepeatMode.none) {
      int queueLenght = queue.value.length;
      return index < queueLenght - 1;
    } else {
      return true;
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    if (shuffleMode == AudioServiceShuffleMode.all) {
      if (_effectiveQueue != queue.value) {
        _effectiveQueue.clear();
        _effectiveQueue.addAll(queue.value);
      }
      if (mediaItem.value != null) {
        List<MediaItem> queueListShuffle = queue.value;
        queueListShuffle
            .removeWhere((element) => element.id == mediaItem.value?.id);
        queueListShuffle.shuffle();
        queueListShuffle.insert(0, mediaItem.value!);
        queue.add(queueListShuffle);
      } else {
        queue.add(queue.value..shuffle());
      }
      index = queue.value.indexWhere((e) => e.id == mediaItem.value!.id);
    } else {
      queue.add(_effectiveQueue.copyList);
      index = queue.value.indexWhere((e) => e.id == mediaItem.value?.id);
    }
    _broadcastState(shuffleMode: shuffleMode);
  }

  void _broadcastState({
    AudioServiceRepeatMode? repeatMode,
    AudioServiceShuffleMode? shuffleMode,
  }) {
    final playing = player.playing;
    playbackState.add(playbackState.value.copyWith(
      controls: connectedSongService.isAdmin
          ? [
              MediaControl.skipToPrevious,
              playing ? MediaControl.pause : MediaControl.play,
              MediaControl.skipToNext
            ]
          : [],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices:
          connectedSongService.isAdmin ? const [0, 1, 2] : [],
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
      repeatMode: repeatMode ?? this.repeatMode,
      shuffleMode: shuffleMode ?? this.shuffleMode,
    ));
  }

  @override
  Future<void> stop() async {
    await pause();
    if (!appIsRunnig) {
      await listeningSongService.deleteUserIdFromLastListenedSongId();
      await userStatusService.updateConenctionType(ConnectionType.DontConnect);
      if (connectedSongService.userId != null) {
        UserStatusService().disconnectUserSong(connectedSongService.userId!);
      }
    }
    return super.stop();
  }
}
