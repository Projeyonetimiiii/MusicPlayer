import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:onlinemusic/services/storage_bloc.dart';

class MyData extends ChangeNotifier {
  late StorageBlock _storageBlock;
  List<MapEntry<int, Uint8List?>> songsImages = [];
  List<SongModel> songs = [];

  MyData() {
    init();
  }

  StorageBlock get sB => _storageBlock;

  void dispose() {}

  Future<void> init() async {
    _storageBlock = StorageBlock();
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
    } else {
      print("İzin Verilmedi");
    }
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
