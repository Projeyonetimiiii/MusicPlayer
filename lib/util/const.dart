import 'package:flutter/material.dart';
import 'package:onlinemusic/models/genre.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class Const {
  static const String kDefaultProfilePicture =
      "https://firebasestorage.googleapis.com/v0/b/onlinemusicnew-22821.appspot.com/o/profile_pictures%2Fdefault_profile_picture.jpg?alt=media&token=bd225467-9ba8-4fa5-aaeb-8d713e447176";

  static const String kDefaultImageUrl =
      "https://firebasestorage.googleapis.com/v0/b/onlinemusicnew-22821.appspot.com/o/audio_images%2Fdefault_audio_image.png?alt=media&token=571a469a-2e3d-46e3-84f0-a351c5308f0d";

  static const Color kWhite = Colors.white;

  static List<Genre> genres = [
    Genre(id: 1, name: "Rock"),
    Genre(id: 2, name: "Caz"),
    Genre(id: 3, name: "Klasik"),
    Genre(id: 4, name: "Rap"),
    Genre(id: 5, name: "Soundtrack"),
    Genre(id: 6, name: "Blues"),
    Genre(id: 7, name: "R&B"),
    Genre(id: 8, name: "Progresif"),
    Genre(id: 9, name: "Heavy"),
    Genre(id: 10, name: "Kelt"),
    Genre(id: 11, name: "Punk"),
    Genre(id: 12, name: "Pop "),
  ];

  static Future<String> getAudioUrlFromVideoId(String videoId) async {
    YoutubeExplode youtubeExplode = YoutubeExplode();
    StreamManifest manifest =
        await youtubeExplode.videos.streamsClient.getManifest(videoId);
    return manifest.audioOnly.withHighestBitrate().url.toString();
  }

  static String getDurationString(Duration duration) {
    return duration.toString().split(".").first.split(":").sublist(1).join(":");
  }
}
