import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:onlinemusic/models/audio.dart';
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

  Future<T?> pushAndRemoveUntil<T>(Widget page) {
    return Navigator.pushAndRemoveUntil(
      this,
      MaterialPageRoute(builder: (_) => page),
      (_) => false,
    );
  }

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
      artUri: Uri.parse(thumbnails.highResUrl),
      extras: {
        "type": ModelType.Video.index,
        "isOnline": true,
        "image": QualityImage(
          maxQualityImageUrl: thumbnails.highResUrl,
          lowQualityImageUrl: thumbnails.lowResUrl,
        ).toMap(),
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
      duration: Duration(milliseconds: duration ?? 0),
      extras: {
        "url": data,
        "type": ModelType.SongModel.index,
        "isOnline": false,
      },
    );
  }
}

extension AudioExt on Audio {
  MediaItem get toMediaItem {
    return MediaItem(
      id: id.toString(),
      title: title,
      album: "User",
      artist: artist,
      duration: duration,
      artUri: Uri.parse(image),
      extras: {
        "url": url,
        "type": ModelType.Audio.index,
        "isOnline": true,
        "image": QualityImage.fromUrl(image).toMap(),
      },
    );
  }
}

extension MediaItemExt on MediaItem {
  Widget get getImageWidget {
    Widget errorWidget = Container(
      color: Colors.grey.shade300,
      child: Center(child: Icon(Icons.image_not_supported_rounded)),
    );
    if (isOnline) {
      return Image.network(
        artUri!.toString(),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return errorWidget;
        },
      );
    } else {
      int? id = int.tryParse(this.id);

      if (id == null) {
        return errorWidget;
      }
      return FutureBuilder<Uint8List?>(
        future: OnAudioQuery.platform.queryArtwork(id, ArtworkType.AUDIO),
        builder: (c, snap) {
          if (!snap.hasData) {
            return errorWidget;
          } else {
            return Image.memory(
              snap.data!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return errorWidget;
              },
            );
          }
        },
      );
    }
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
  bool get isAudio => this == ModelType.Audio;
  bool get isSongModel => this == ModelType.SongModel;
}
