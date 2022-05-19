import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:onlinemusic/services/audios_bloc.dart';
import 'package:onlinemusic/services/background_audio_handler.dart';
import 'package:onlinemusic/services/storage_bloc.dart';
import 'package:path_provider/path_provider.dart';

class MyData extends ChangeNotifier {
  late StorageBloc _storageBloc;
  late AudiosBloc _audiosBloc;
  List<MapEntry<int, Uint8List?>> songsImages = [];
  List<SongModel> songs = [];
  late BackgroundAudioHandler handler;

  MyData() {
    init();
  }

  StorageBloc get sB => _storageBloc;
  AudiosBloc get aB => _audiosBloc;

  void dispose() {}

  Future<void> init() async {
    _storageBloc = StorageBloc();
    _audiosBloc = AudiosBloc();
    handler = await AudioService.init(
      builder: () => BackgroundAudioHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelName: "Müzik",
        androidNotificationChannelDescription: "Müzik Bildirimi",
      ),
    );
    getMusics();
  }

  Future<void> getMusics() async {
    bool result = await _requestPermission();
    if (result) {
      List<SongModel> songsModel =
          getFilteredSongs(await OnAudioQuery().querySongs(), 60);
      for (var song in songsModel) {
        songsImages.add(MapEntry<int, Uint8List?>(
            song.id,
            await OnAudioQuery()
                .queryArtwork(song.id, ArtworkType.AUDIO, size: 200)));
      }
      songs = songsModel;
      notifyListeners();
    } else {
      print("İzin Verilmedi");
    }
  }

  Uint8List? getBytesFromSongId(int id) {
    try {
      return songsImages[songsImages.indexWhere((e) => e.key == id)].value;
    } catch (e) {
      return null;
    }
  }

  Future<String?> saveImage(SongModel song) async {
    Uint8List? bytes = getBytesFromSongId(song.id);
    if (bytes != null) {
      String? path = await getFilePathFromBytes(bytes, song.title, song.artist);
      print(path);
      return path;
    }
    return null;
  }

  Future<String?> getFilePathFromBytes(
      Uint8List? bytes, String title, String? artist) async {
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
        filePath = null;
      }
    }
    return filePath;
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
}
