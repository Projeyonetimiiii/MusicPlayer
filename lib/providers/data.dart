import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/models/my_playlist.dart';
import 'package:onlinemusic/models/youtube_playlist.dart';
import 'package:onlinemusic/services/download_service.dart';
import 'package:onlinemusic/services/storage_bloc.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/converter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:rxdart/rxdart.dart';

enum LoadedType { PermissionDenied, Loading, Loaded, None }

class MyData extends ChangeNotifier {
  late StorageBloc _storageBloc;
  List<MapEntry<int, String>> songsImage = [];
  late BehaviorSubject<List<MediaItem>> songs;
  late BehaviorSubject<List<MediaItem>> favoriteSongs;
  late BehaviorSubject<List<YoutubePlaylist>> favoriteLists;
  late BehaviorSubject<LoadedType> loadedType;
  late BehaviorSubject<List<MyPlaylist>> myPlaylists;

  bool? isEmpty;

  String defaultImagePath = "";
  MyData() {
    init();
  }

  StorageBloc get sB => _storageBloc;
  Future<void> init() async {
    _storageBloc = StorageBloc();
    loadedType = BehaviorSubject.seeded(LoadedType.None);
    favoriteSongs = BehaviorSubject.seeded([]);
    favoriteLists = BehaviorSubject.seeded([]);
    myPlaylists = BehaviorSubject.seeded([]);
    songs = BehaviorSubject.seeded([]);
    myPlaylists.add(getPlaylists);
    favoriteSongs.add(_getFavoriteSong());
    favoriteLists.add(_getFavoriteLists());
    getSongsFromHive();
    getMusics();
    getDownlaodQueue();
  }

  void getDownlaodQueue() {
    List<String>? strings = songsBox!.get("downloadQueue", defaultValue: []);
    if (strings != null && strings.isNotEmpty) {
      List<MediaItem> items =
          strings.map((e) => MediaItemConverter.jsonToMediaItem(e)).toList();
      downloadService.downloadQueue = items;
    }
  }

  Future<void> getMusics() async {
    bool result = await _requestPermission();
    if (result) {
      if (songs.value.isNotEmpty) {
        loadedType.add(LoadedType.Loaded);
      } else {
        loadedType.add(LoadedType.Loading);
      }
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
      songs.add(songsModel.map((e) => e.toMediaItem).toList());
      saveSongs();
      loadedType.add(LoadedType.Loaded);
      notifyListeners();
    } else {
      loadedType.add(LoadedType.PermissionDenied);
      print("İzin Verilmedi");
    }
  }

  void saveSongs() {
    songsBox!.put("localSongs", songs.value.map((e) => e.toJson).toList());
  }

  void getSongsFromHive() {
    List<String>? songJsons = songsBox!.get(
      "localSongs",
    );
    if (songJsons != null) {
      songs.add(
          songJsons.map((e) => MediaItemConverter.jsonToMediaItem(e)).toList());
      loadedType.add(LoadedType.Loaded);
    }
  }

  String getImagePathFromSongId(int id) {
    return songsImage[songsImage.indexWhere((e) => e.key == id)].value;
  }

  Future<String?> saveImage(MediaItem song) async {
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
      try {
        bool res = await OnAudioQuery().permissionsRequest();
        return res;
      } on Exception catch (_) {
        return false;
      }
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
      return Icon(
        Icons.repeat_one_rounded,
        color: Const.contrainsColor,
      );
    } else if (mode == AudioServiceRepeatMode.all) {
      return Icon(
        Icons.repeat,
        color: Const.contrainsColor,
      );
    } else
      return Icon(
        Icons.repeat_rounded,
        color: Const.contrainsColor.withOpacity(0.6),
      );
  }

  List<YoutubePlaylist> _getFavoriteLists() {
    List<String> songJsons = songsBox!.get("favoriteLists", defaultValue: [])!;
    return songJsons.map((e) => YoutubePlaylist.fromJson(e)).toList();
  }

  List<MediaItem> _getFavoriteSong() {
    List<String> songJsons = songsBox!.get("favorites", defaultValue: [])!;
    return songJsons.map((e) => MediaItemConverter.jsonToMediaItem(e)).toList();
  }

  void removeFavoritedSong(MediaItem item) {
    List<MediaItem> items = _getFavoriteSong();
    if (items.any((element) => element.id == item.id)) {
      items.removeWhere((element) => element.id == item.id);
      favoriteSongs.add(items);
      saveFavoriteSongs(items);
    }
  }

  Future<void> saveFavoriteSongs(List<MediaItem> items) async {
    List<String> value = items.map((e) => e.toJson).toList();
    await songsBox!.put("favorites", value);
  }

  void addFavoriteSong(MediaItem item) {
    List<MediaItem> items = _getFavoriteSong();
    if (!items.any((element) => element.id == item.id)) {
      items.add(item);
      favoriteSongs.add(items);
      saveFavoriteSongs(items);
    }
  }

  void changeFavoriteSong(MediaItem song) {
    if (favoriteSongs.value.any((element) => element.id == song.id)) {
      removeFavoritedSong(song);
    } else {
      addFavoriteSong(song);
    }
  }

  void changeFavoriteList(YoutubePlaylist playlist) {
    if (favoriteLists.value
        .any((element) => element.playlistId == playlist.playlistId)) {
      removeFavoritedList(playlist);
    } else {
      addFavoriteList(playlist);
    }
  }

  void removeFavoritedList(YoutubePlaylist item) {
    List<YoutubePlaylist> items = _getFavoriteLists();
    if (items.any((element) => element.playlistId == item.playlistId)) {
      items.removeWhere((element) => element.playlistId == item.playlistId);
      favoriteLists.add(items);
      saveFavoriteList(items);
    }
  }

  Future<void> saveFavoriteList(List<YoutubePlaylist> items) async {
    List<String> value = items.map((e) => e.toJson()).toList();
    await songsBox!.put("favoriteLists", value);
  }

  void addFavoriteList(YoutubePlaylist item) {
    List<YoutubePlaylist> items = _getFavoriteLists();
    if (!items.any((element) => element.playlistId == item.playlistId)) {
      items.add(item);
      favoriteLists.add(items);
      saveFavoriteList(items);
    }
  }

  void removePlaylist(MyPlaylist playlist) {
    List<MyPlaylist> playlists = getPlaylists;
    playlists.removeWhere((element) => element.name == playlist.name);
    savePlaylist(playlists);
  }

  String getPlaylistName(String name) {
    List<MyPlaylist> playlists = getPlaylists;
    if (playlists.any((element) => element.name == name)) {
      int counter = 1;
      while (playlists.any((element) =>
          element.name == name + " (" + counter.toString() + ")")) {
        counter++;
      }
      name += " (" + counter.toString() + ")";
    }
    return name;
  }

  void addPlaylistFromMyPlaylist(MyPlaylist playlist) async {
    List<MyPlaylist> playlists = getPlaylists;
    playlist = playlist.copyWith(
      name: getPlaylistName(playlist.name),
    );
    playlists.add(playlist);
    savePlaylist(playlists);
  }

  void addPlaylist(String name) async {
    List<MyPlaylist> playlists = getPlaylists;
    name = getPlaylistName(name);
    playlists
        .add(MyPlaylist(createdDate: DateTime.now(), name: name, songs: []));
    savePlaylist(playlists);
  }

  void updatePlaylist(MyPlaylist playlist, {bool checkName = false}) async {
    List<MyPlaylist> playlists = getPlaylists;
    int index = playlists.indexWhere((element) =>
        element.createdDate.millisecondsSinceEpoch ==
        playlist.createdDate.millisecondsSinceEpoch);
    if (index != -1) {
      if (checkName) {
        playlist = playlist.copyWith(
          name: getPlaylistName(playlist.name),
        );
      }
      playlists[index] = playlist;
      savePlaylist(playlists);
    }
  }

  void savePlaylist(List<MyPlaylist> playlists) {
    myPlaylists.add(playlists);
    playlistsBox!.put("playlists", playlists.map((e) => e.toJson()).toList());
  }

  List<MyPlaylist> get getPlaylists {
    List<String>? playlistJsons = playlistsBox!.get("playlists");
    if (playlistJsons != null) {
      return playlistJsons.map((e) => MyPlaylist.fromJson(e)).toList();
    } else {
      return [];
    }
  }
}
