import 'package:flutter/material.dart';
import 'package:onlinemusic/services/theme_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class Const {
  static const String kDefaultProfilePicture =
      "https://firebasestorage.googleapis.com/v0/b/onlinemusicnew-22821.appspot.com/o/profile_pictures%2Fdefault_profile_picture.jpg?alt=media&token=bd225467-9ba8-4fa5-aaeb-8d713e447176";

  static const String kDefaultImageUrl =
      "https://firebasestorage.googleapis.com/v0/b/onlinemusicnew-22821.appspot.com/o/audio_images%2Fdefault_audio_image.png?alt=media&token=571a469a-2e3d-46e3-84f0-a351c5308f0d";

  static const Color kWhite = Colors.white;
  static const Color kBackground = Color(0xFF02001D);
  static Color kLight = Colors.grey.shade200;
  // static const Color kBackground1 = Color(0xFF02001D);
  static Color get contrainsColor {
    if (ThemeService().isLight) return Const.kBackground;
    return Colors.grey.shade200;
  }

  static Color get themeColor {
    if (ThemeService().isLight) return Colors.grey.shade200;
    return Const.kBackground;
  }

  static String getPlaylistsUrl(String query) {
    return "https://www.youtube.com/results?search_query=${query}&sp=EgIQAw%253D%253D";
  }

  static Future<String> getAudioUrlFromVideoId(String videoId) async {
    YoutubeExplode youtubeExplode = YoutubeExplode();
    StreamManifest manifest =
        await youtubeExplode.videos.streamsClient.getManifest(videoId);
    return manifest.audioOnly.withHighestBitrate().url.toString();
  }

  static String getDurationString(Duration duration) {
    return duration.toString().split(".").first.split(":").sublist(1).join(":");
  }

  static String getDateTimeString(DateTime time) {
    return time.toString().split(".").first;
  }

  static String timeEllapsed(DateTime time) {
    var now = DateTime.now();
    Duration diff = now.difference(time);

    String timeEllapse = "";

    if (diff.inDays < 1) {
      timeEllapse = _getNum(time.hour) + ":" + _getNum(time.minute);
    } else if (diff.inDays == 1) {
      timeEllapse = "Dün";
    } else {
      timeEllapse = _getNum(time.day) +
          "." +
          _getNum(time.month) +
          "." +
          _getNum(time.year);
    }
    return timeEllapse;
  }

  static String _getNum(int time) {
    if (time < 10) {
      return "0" + time.toString();
    } else {
      return time.toString();
    }
  }
}
