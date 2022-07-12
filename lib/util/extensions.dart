import 'dart:convert';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/models/quality_image.dart';
import 'package:onlinemusic/providers/data.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/enums.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

extension BuildContextExt on BuildContext {
  Future<T?> push<T>(Widget page) {
    return Navigator.push(this, MaterialPageRoute(builder: (_) => page));
  }

  Future<T?> pushOpaque<T>(Widget page) {
    return Navigator.of(this).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (_, __, ___) => page,
    ));
  }

  Future<T?> pushAndRemoveUntil<T>(Widget page) {
    return Navigator.pushAndRemoveUntil(
      this,
      MaterialPageRoute(builder: (_) => page),
      (_) => false,
    );
  }

  Size get getSize => MediaQuery.of(this).size;
  MyData get myData => this.read<MyData>();
}

extension VideoExt on Video {
  MediaItem get toMediaItem {
    return MediaItem(
      id: id.value,
      title: title,
      album: "Youtube",
      artist: author,
      duration: duration,
      artUri: Uri.parse(thumbnails.mediumResUrl),
      extras: {
        "type": ModelType.Video.index,
        "isOnline": true,
        "image": QualityImage(
          maxQualityImageUrl: thumbnails.highResUrl,
          lowQualityImageUrl: thumbnails.lowResUrl,
        ).toMap(),
        "dateAdded": publishDate?.millisecondsSinceEpoch,
      },
    );
  }
}

extension SongModelExt on SongModel {
  MediaItem get toMediaItem {
    return MediaItem(
      id: id.toString(),
      title: title,
      album: album,
      artist: artist,
      artUri: Uri.file(getImagePath),
      duration: Duration(milliseconds: duration ?? 0),
      extras: {
        "url": data,
        "type": ModelType.SongModel.index,
        "isOnline": false,
        "dateAdded": dateAdded,
      },
    );
  }

  String get getImagePath {
    MyData data = MyApp.navigatorKey.currentContext!.myData;
    return data.getImagePathFromSongModel(this);
  }
}

extension MediaItemExt on MediaItem {
  Widget get getImageWidget {
    Widget errorWidget = Image.asset(
      "assets/images/default_song_image.png",
      fit: BoxFit.cover,
    );
    if (isOnline) {
      return CachedNetworkImage(
        imageUrl: artUri!.toString(),
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) {
          return errorWidget;
        },
        placeholder: (c, i) {
          return errorWidget;
        },
      );
    } else {
      return Image.file(
        File(artUri!.toFilePath()),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return errorWidget;
        },
      );
    }
  }

  String get maxImageUrl {
    return extras!["image"]["maxQualityImageUrl"];
  }

  Map<String, dynamic> get toMap {
    return {
      "id": id,
      "title": title,
      "artUri": this.artUri.toString(),
      "duration": this.duration?.inMilliseconds ?? 0,
      "album": this.album,
      "artist": this.artist,
      "genre": this.genre,
      "extras": this.extras,
    };
  }

  String get toJson {
    return jsonEncode(toMap);
  }

  Future<String?> get source async {
    if (type.isVideo) {
      return Const.getAudioUrlFromVideoId(id);
    } else {
      return extras?["url"];
    }
  }

  bool get isHaveUrl => extras?["url"] != null;
  bool get isOnline => extras?["isOnline"] ?? false;
  ModelType get type => ModelType.values[extras?["type"] ?? 0];
}

extension ModelTypeExt on ModelType {
  bool get isVideo => this == ModelType.Video;
  bool get isSongModel => this == ModelType.SongModel;
}

extension ListExt<T> on List<T> {
  List<T> get copyList {
    List<T> temp = [];
    for (var item in this) {
      temp.add(item);
    }
    return temp;
  }
}

extension ConnectionTypeExt on ConnectionType {
  bool get isReady => this == ConnectionType.Ready;
}

extension RequestTypeExt on RequestType {
  bool get isUser => this == RequestType.User;
}

extension BuildMusicListTypeExt on BuildMusicListType {
  bool get isFavorite => this == BuildMusicListType.Favorite;
  bool get isQueue => this == BuildMusicListType.Queue;
  bool get isDownloaded => this == BuildMusicListType.Downloaded;
}
