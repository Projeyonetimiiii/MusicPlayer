import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/services/audios_bloc.dart';
import 'package:onlinemusic/services/storage_bloc.dart';
import 'package:onlinemusic/util/converter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:onlinemusic/util/extensions.dart';

class MyData extends ChangeNotifier {
  late StorageBloc _storageBloc;
  late AudiosBloc _audiosBloc;
  List<MapEntry<int, String>> songsImage = [];
  List<SongModel> songs = [];

  bool? isEmpty;

  String defaultImagePath = "";
  MyData() {
    init();
  }

  StorageBloc get sB => _storageBloc;
  AudiosBloc get aB => _audiosBloc;

  void dispose() {}

  Future<void> init() async {
    _storageBloc = StorageBloc();
    _audiosBloc = AudiosBloc();
    getMusics();
  }

  Future<void> getMusics() async {
    bool result = await _requestPermission();
    if (result) {
      List<SongModel> songsModel =
          getFilteredSongs(await OnAudioQuery().querySongs(), 60);
      for (var song in songsModel) {
        songsImage.add(MapEntry<int, String>(
            song.id,
            (await getFilePathFromBytes(
                await OnAudioQuery()
                    .queryArtwork(song.id, ArtworkType.AUDIO, size: 200),
                song.title,
                song.artist,
                default_image: true))!));
      }
      songs = songsModel;
      notifyListeners();
    } else {
      print("İzin Verilmedi");
    }
  }

  String getImagePathFromSongId(int id) {
    return songsImage[songsImage.indexWhere((e) => e.key == id)].value;
  }

  Future<String?> saveImage(MediaItem song) async {
    // Uint8List? bytes = getBytesFromSongId(song.id);
    // if (bytes != null) {
    //   String? path = await getFilePathFromBytes(bytes, song.title, song.artist);
    //   print(path);
    //   return path;
    // }
    return getImagePathFromSongId(int.parse(song.id));
  }

  String getImagePathFromSongModel(SongModel song) {
    return getImagePathFromSongId(song.id);
  }

  Future<String?> getFilePathFromBytes(
      Uint8List? bytes, String title, String? artist,
      {bool default_image = false}) async {
    String tempDir = (await getTemporaryDirectory()).path;
    String? filePath;
    if (bytes != null) {
      try {
        final File file = File(
            '$tempDir/${title.toString().replaceAll('/', '')}-${artist.toString().replaceAll('/', '')}.jpg');
        filePath = file.path;
        if (!await file.exists()) {
          await file.create();
          file.writeAsBytesSync(bytes);
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    if (default_image) {
      if (filePath == null) {
        filePath = await _getImageFileFromAssets();
      }
    }
    return filePath;
  }

  Future<String> _getImageFileFromAssets() async {
    if (defaultImagePath != '') return defaultImagePath;
    final file =
        File('${(await getTemporaryDirectory()).path}/default_image.jpg');
    defaultImagePath = file.path;
    if (await file.exists()) return file.path;
    final byteData =
        await rootBundle.load('assets/images/default_song_image.png');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file.path;
  }

  List<SongModel> getFilteredSongs(List<SongModel> songs, int second) {
    return songs
        .where((element) => (element.duration ?? 0) > second * 1000)
        .toList();
  }

  Future<bool> _requestPermission() async {
    bool permissionStatus = await OnAudioQuery().permissionsStatus();
    if (!permissionStatus) {
      return await OnAudioQuery().permissionsRequest();
    }
    return true;
  }

  Future<void> setRepeatMode() async {
    AudioServiceRepeatMode mode = handler.playbackState.value.repeatMode;
    if (mode == AudioServiceRepeatMode.none) {
      await handler.setRepeatMode(AudioServiceRepeatMode.one);
    } else if (mode == AudioServiceRepeatMode.one) {
      await handler.setRepeatMode(AudioServiceRepeatMode.all);
    } else {
      await handler.setRepeatMode(AudioServiceRepeatMode.none);
    }
  }

  Icon getRepeatModeIcon(AudioServiceRepeatMode mode) {
    if (mode == AudioServiceRepeatMode.one) {
      return Icon(Icons.repeat_one_rounded);
    } else if (mode == AudioServiceRepeatMode.all) {
      return Icon(Icons.repeat);
    } else
      return Icon(
        Icons.repeat_rounded,
        color: Colors.black45,
      );
  }

  List<MediaItem> getFavoriteSong() {
    List<String> songJsons = favoriteBox!.get("songs", defaultValue: [])!;
    return songJsons.map((e) => MediaItemConverter.jsonToMediaItem(e)).toList();
  }

  void removeFavoritedSong(MediaItem item) {
    List<MediaItem> items = getFavoriteSong();
    if (items.any((element) => element.id == item.id)) {
      items.removeWhere((element) => element.id == item.id);
      saveFavoriteSongs(items);
    }
  }

  Future<void> saveFavoriteSongs(List<MediaItem> items) async {
    List<String> value = items.map((e) => e.toJson).toList();
    await favoriteBox!.put("songs", value);
  }

  void addFavoriteSong(MediaItem item) {
    List<MediaItem> items = getFavoriteSong();
    if (!items.any((element) => element.id == item.id)) {
      items.add(item);
      saveFavoriteSongs(items);
    }
  }
}
