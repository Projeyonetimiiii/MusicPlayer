import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/audio.dart';
import '../util/const.dart';

Widget firebaseCard({required Audio audio}) {
  return ListTile(
    leading: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        audio.image,
        fit: BoxFit.cover,
      ),
    ),
    title: Text(
      audio.title ?? "",
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    ),
    trailing: Text(audio.duration.toString()),
  );
}

Widget localMusic(SongModel e) {
  return ListTile(
    leading: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: FutureBuilder<Uint8List?>(
        future: OnAudioQuery.platform.queryArtwork(e.id, ArtworkType.AUDIO),
        builder: (c, snap) {
          if (!snap.hasData) {
            return Icon(Icons.hide_image_rounded);
          } else {
            return Image.memory(
              snap.data!,
              fit: BoxFit.cover,
            );
          }
        },
      ),
    ),
    title: Text(
      e.title ?? "",
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    ),
    trailing: Text(e.duration.toString()),
  );
}

Widget youtubeCard({required Video video}) {
  return ListTile(
    leading: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        video.url,
        fit: BoxFit.cover,
      ),
    ),
    title: Text(
      video.title ?? "",
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    ),
    trailing: Text(video.duration.toString()),
  );
}
