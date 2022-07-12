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

  StreamSubscription? playbackEvent;
  StreamSubscription? processingState;

  BackgroundAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    playbackEvent = player.playbackEventStream.listen((s) {
      _broadcastState();
    });
    processingState = player.processingStateStream.listen((event) async {
      if (event == ProcessingState.completed) {
        skipItem();
      }
    });
  }

  void skipItem({int skip = 1}) async {
    if (!connectedSongService.isAdmin) {
      return;
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
    cacheBox!.put(
      "lastQueue",
      newQueue.map((e) => e.toJson).toList(),
    );
    return super.updateQueue(newQueue);
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem1) async {
    updateMediaItemIndex(mediaItem1);
    if (mediaItem.value?.id != mediaItem1.id) {
      await updatePlayingMediaItem(mediaItem1);
    }
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
  Future<void> pause() async {
    player.pause();
  }

  void updateMediaItemIndex(MediaItem mediaItem1) {
    if (queue.value.any((e) => e.id == mediaItem1.id)) {
      index = queue.value.indexWhere((e) => e.id == mediaItem1.id);
      _broadcastState();
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
      player.pause();
      url = await mediaItem1.source;
    }
    if (url == null) return;
    cacheBox!.put("lastMediaItem", mediaItem1.toJson);
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
  Future<void> insertQueueItem(int index, MediaItem mediaItem) {
    _effectiveQueue.insert(index, mediaItem);
    List<MediaItem> newList = queue.value.toList();
    newList.insert(index, mediaItem);
    cacheBox!.put(
      "lastQueue",
      newList.map((e) => e.toJson).toList(),
    );
    return super.insertQueueItem(index, mediaItem);
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) {
    _effectiveQueue.remove(mediaItem);
    cacheBox!.put(
      "lastQueue",
      queue.value.map((e) => e.toJson).toList(),
    );
    if (this.mediaItem.value != null) {
      updateMediaItemIndex(this.mediaItem.value!);
    }
    return super.removeQueueItem(mediaItem);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) {
    _effectiveQueue.add(mediaItem);
    List<MediaItem> newList = queue.value.toList();
    newList.add(mediaItem);
    cacheBox!.put(
      "lastQueue",
      newList.map((e) => e.toJson).toList(),
    );
    return super.addQueueItem(mediaItem);
  }

  @override
  Future customAction(String name, [Map<String, dynamic>? extras]) {
    if (name == 'sleepTimer') {
      _sleepTimer?.cancel();
      if (extras?['time'] != null &&
          extras!['time'].runtimeType == int &&
          extras['time'] > 0 as bool) {
        _sleepTimer = Timer(Duration(minutes: extras['time'] as int), () {
          if (connectedSongService.isAdmin) {
            stop();
          }
        });
      }
    }

    return super.customAction(name, extras);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < queue.value.length && index > -1) {
      // if(!connectedSongService.isAdmin) await pause();
      await playMediaItem(queue.value[index]);
      if (!connectedSongService.isConnectedSong) {
        play();
      }
    }
    return super.skipToQueueItem(index);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    cacheBox!.put(
      "lastRepeatMode",
      repeatMode.index,
    );
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
    cacheBox!.put(
      "lastShuffleMode",
      shuffleMode.index,
    );
    cacheBox!.put(
      "lastQueue",
      queue.value.map((e) => e.toJson).toList(),
    );
    _broadcastState(shuffleMode: shuffleMode);
  }

  void _broadcastState({
    AudioServiceRepeatMode? repeatMode,
    AudioServiceShuffleMode? shuffleMode,
  }) {
    final playing = player.playing;

    AudioProcessingState processingState = getProcessingState();

    playbackState.add(
      playbackState.value.copyWith(
        controls: connectedSongService.isAdmin
            ? [
                MyMediaControls.skipToPrevious,
                playing ? MyMediaControls.pause : MyMediaControls.play,
                MyMediaControls.skipToNext
              ]
            : [],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices:
            connectedSongService.isAdmin ? const [0, 1, 2] : [],
        processingState: processingState,
        playing: playing,
        updatePosition: player.position,
        bufferedPosition: player.bufferedPosition,
        speed: player.speed,
        queueIndex: index,
        repeatMode: repeatMode ?? this.repeatMode,
        shuffleMode: shuffleMode ?? this.shuffleMode,
      ),
    );
  }

  AudioProcessingState getProcessingState() {
    AudioProcessingState state = const {
      ProcessingState.idle: AudioProcessingState.idle,
      ProcessingState.loading: AudioProcessingState.loading,
      ProcessingState.buffering: AudioProcessingState.buffering,
      ProcessingState.ready: AudioProcessingState.ready,
      ProcessingState.completed: AudioProcessingState.completed,
    }[player.processingState]!;

    if (!appIsRunnig) {
      if (state == AudioProcessingState.idle) {
        state = AudioProcessingState.loading;
      }
    }
    return state;
  }

  @override
  Future<void> stop() async {
    await player.stop();
    await playbackState.firstWhere(
      (state) => state.processingState == AudioProcessingState.idle,
    );
    if (!appIsRunnig) {
      await listeningSongService.deleteUserIdFromLastListenedSongId();
      await userStatusService.updateConenctionType(ConnectionType.DontConnect);
      if (connectedSongService.userId != null) {
        UserStatusService().disconnectUserSong(connectedSongService.userId!);
      }
      mediaItem.add(null);
      player.stop();
      _sleepTimer?.cancel();
      _sleepTimer = null;
      _effectiveQueue = [];
      playbackEvent?.cancel();
      processingState?.cancel();
      playbackEvent = null;
      processingState = null;
    }
    return super.stop();
  }
}

class MyMediaControls {
  /// A default control for [MediaAction.pause].
  static const pause = MediaControl(
    androidIcon: 'drawable/pause',
    label: 'Pause',
    action: MediaAction.pause,
  );

  /// A default control for [MediaAction.play].
  static const play = MediaControl(
    androidIcon: 'drawable/play',
    label: 'Play',
    action: MediaAction.play,
  );

  /// A default control for [MediaAction.skipToNext].
  static const skipToNext = MediaControl(
    androidIcon: 'drawable/next',
    label: 'Next',
    action: MediaAction.skipToNext,
  );

  /// A default control for [MediaAction.skipToPrevious].
  static const skipToPrevious = MediaControl(
    androidIcon: 'drawable/geri',
    label: 'Previous',
    action: MediaAction.skipToPrevious,
  );
}
