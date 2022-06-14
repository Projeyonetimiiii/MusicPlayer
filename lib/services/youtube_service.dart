import 'dart:convert';

import 'package:http/http.dart';
import 'package:onlinemusic/models/head_music.dart';
import 'package:onlinemusic/models/youtube_genre.dart';
import 'package:onlinemusic/models/youtube_musics.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YouTubeServices {
  String searchAuthority = 'www.youtube.com';
  String musicPath = "/music";

  final YoutubeExplode yt = YoutubeExplode();

  Future<List<Video>> getPlaylistSongs(String id) async {
    final List<Video> results = await yt.playlists.getVideos(id).toList();
    return results;
  }

  Future<Playlist> getPlaylistDetails(String id) async {
    final Playlist metadata = await yt.playlists.get(id);
    return metadata;
  }

  Future<YoutubeMusics?> getMusicHome() async {
    final Uri link = Uri.https(
      searchAuthority,
      musicPath,
    );
    final Response response = await get(link);
    if (response.statusCode != 200) {
      return null;
    }
    final String searchResults =
        RegExp(r'(\"contents\":{.*?}),\"metadata\"', dotAll: true)
            .firstMatch(response.body)![1]!;
    final Map data = json.decode('{$searchResults}') as Map;

    final List result = data['contents']['twoColumnBrowseResultsRenderer']
            ['tabs'][0]['tabRenderer']['content']['sectionListRenderer']
        ['contents'] as List;

    final List headResult = data['header']['carouselHeaderRenderer']['contents']
        [0]['carouselItemRenderer']['carouselItems'] as List;

    final List shelfRenderer = result.map((element) {
      return element['itemSectionRenderer']['contents'][0]['shelfRenderer'];
    }).toList();

    final List finalResult = shelfRenderer.map((element) {
      if (element['title']['runs'][0]['text'].trim() !=
          'Highlights from Global Citizen Live') {
        return {
          'title': element['title']['runs'][0]['text'],
          'playlists': element['title']['runs'][0]['text'].trim() == 'Listeler'
              ? formatChartItems(
                  element['content']['horizontalListRenderer']['items'] as List)
              : element['title']['runs'][0]['text'].trim() ==
                      'Yeni Müzik Videoları'
                  ? formatVideoItems(element['content']
                      ['horizontalListRenderer']['items'] as List)
                  : formatItems(element['content']['horizontalListRenderer']
                      ['items'] as List),
        };
      } else {
        return null;
      }
    }).toList();

    final List finalHeadResult = formatHeadItems(headResult);
    finalResult.removeWhere((element) => element == null);
    List<YoutubeGenre> genres =
        finalResult.map((e) => YoutubeGenre.fromMap(e)).toList();
    List<HeadMusic> headMusics =
        finalHeadResult.map((e) => HeadMusic.fromMap(e)).toList();

    return YoutubeMusics(headSongs: headMusics, genres: genres);
  }

  List formatVideoItems(List itemsList) {
    try {
      final List result = itemsList.map((e) {
        return {
          'title': e['gridVideoRenderer']['title']['simpleText'],
          'type': 'video',
          'description': e['gridVideoRenderer']['shortBylineText']['runs'][0]
              ['text'],
          'count': e['gridVideoRenderer']['shortViewCountText']['simpleText'],
          'videoId': e['gridVideoRenderer']['videoId'],
          'firstItemId': e['gridVideoRenderer']['videoId'],
          'image':
              e['gridVideoRenderer']['thumbnail']['thumbnails'].last['url'],
          'imageMin': e['gridVideoRenderer']['thumbnail']['thumbnails'][0]
              ['url'],
          'imageMedium': e['gridVideoRenderer']['thumbnail']['thumbnails'][1]
              ['url'],
          'imageStandard': e['gridVideoRenderer']['thumbnail']['thumbnails'][2]
              ['url'],
          'imageMax':
              e['gridVideoRenderer']['thumbnail']['thumbnails'].last['url'],
        };
      }).toList();

      return result;
    } catch (e) {
      return List.empty();
    }
  }

  List formatChartItems(List itemsList) {
    try {
      final List result = itemsList.map((e) {
        return {
          'title': e['gridPlaylistRenderer']['title']['runs'][0]['text'],
          'type': 'chart',
          'description': e['gridPlaylistRenderer']['shortBylineText']['runs'][0]
              ['text'],
          'count': e['gridPlaylistRenderer']['videoCountText']['runs'][0]
              ['text'],
          'playlistId': e['gridPlaylistRenderer']['navigationEndpoint']
              ['watchEndpoint']['playlistId'],
          'firstItemId': e['gridPlaylistRenderer']['navigationEndpoint']
              ['watchEndpoint']['videoId'],
          'image': e['gridPlaylistRenderer']['thumbnail']['thumbnails'][0]
              ['url'],
          'imageMedium': e['gridPlaylistRenderer']['thumbnail']['thumbnails'][0]
              ['url'],
          'imageStandard': e['gridPlaylistRenderer']['thumbnail']['thumbnails']
              [0]['url'],
          'imageMax': e['gridPlaylistRenderer']['thumbnail']['thumbnails'][0]
              ['url'],
        };
      }).toList();

      return result;
    } catch (e) {
      return List.empty();
    }
  }

  List formatItems(List itemsList) {
    try {
      final List result = itemsList.map((e) {
        return {
          'title': e['compactStationRenderer']['title']['simpleText'],
          'type': 'playlist',
          'description': e['compactStationRenderer']['description']
              ['simpleText'],
          'count': e['compactStationRenderer']['videoCountText']['runs'][0]
              ['text'],
          'playlistId': e['compactStationRenderer']['navigationEndpoint']
              ['watchEndpoint']['playlistId'],
          'firstItemId': e['compactStationRenderer']['navigationEndpoint']
              ['watchEndpoint']['videoId'],
          'image': e['compactStationRenderer']['thumbnail']['thumbnails'][0]
              ['url'],
          'imageMedium': e['compactStationRenderer']['thumbnail']['thumbnails']
              [0]['url'],
          'imageStandard': e['compactStationRenderer']['thumbnail']
              ['thumbnails'][1]['url'],
          'imageMax': e['compactStationRenderer']['thumbnail']['thumbnails'][2]
              ['url'],
        };
      }).toList();

      return result;
    } catch (e) {
      return List.empty();
    }
  }

  List formatHeadItems(List itemsList) {
    try {
      final List result = itemsList.map((e) {
        return {
          'title': e['defaultPromoPanelRenderer']['title']['runs'][0]['text'],
          'type': 'video',
          'description':
              (e['defaultPromoPanelRenderer']['description']['runs'] as List)
                  .map((e) => e['text'])
                  .toList()
                  .join(),
          'videoId': e['defaultPromoPanelRenderer']['navigationEndpoint']
              ['watchEndpoint']['videoId'],
          'firstItemId': e['defaultPromoPanelRenderer']['navigationEndpoint']
              ['watchEndpoint']['videoId'],
          'image': e['defaultPromoPanelRenderer']
                          ['largeFormFactorBackgroundThumbnail']
                      ['thumbnailLandscapePortraitRenderer']['landscape']
                  ['thumbnails']
              .last['url'],
          'imageMedium': e['defaultPromoPanelRenderer']
                      ['largeFormFactorBackgroundThumbnail']
                  ['thumbnailLandscapePortraitRenderer']['landscape']
              ['thumbnails'][1]['url'],
          'imageStandard': e['defaultPromoPanelRenderer']
                      ['largeFormFactorBackgroundThumbnail']
                  ['thumbnailLandscapePortraitRenderer']['landscape']
              ['thumbnails'][2]['url'],
          'imageMax': e['defaultPromoPanelRenderer']
                          ['largeFormFactorBackgroundThumbnail']
                      ['thumbnailLandscapePortraitRenderer']['landscape']
                  ['thumbnails']
              .last['url'],
        };
      }).toList();

      return result;
    } catch (e) {
      return List.empty();
    }
  }

  Future<Map?> formatVideo(Video video) async {
    if (video.duration?.inSeconds == null) return null;
    return {
      'id': video.id.value,
      'album': video.author,
      'duration': video.duration?.inSeconds.toString(),
      'title': video.title,
      'artist': video.author,
      'image': video.thumbnails.maxResUrl.toString(),
      'secondImage': video.thumbnails.highResUrl.toString(),
      'language': 'YouTube',
      'genre': 'YouTube',
      'url': await getUri(video),
      'year': video.uploadDate?.year.toString(),
      '320kbps': 'false',
      'has_lyrics': 'false',
      'release_date': video.publishDate.toString(),
      'album_id': video.channelId.value,
      'subtitle': video.author,
      'perma_url': 'https://youtube.com/watch?v=${video.id.value}',
    };
  }

  Future<List<Video>> fetchSearchResults(String query) async {
    final List<Video> searchResults = await yt.search.search(query);

    return searchResults;
  }

  Future<String> getUri(Video videoId) async {
    final StreamManifest manifest =
        await yt.videos.streamsClient.getManifest(videoId.id);
    final AudioOnlyStreamInfo streamInfo =
        manifest.audioOnly.withHighestBitrate();
    return streamInfo.url.toString();
  }

  Future<String> getUriFS(String videoId) async {
    final StreamManifest manifest =
        await yt.videos.streamsClient.getManifest(videoId);
    final AudioOnlyStreamInfo streamInfo =
        manifest.audioOnly.withHighestBitrate();
    return streamInfo.url.toString();
  }
}

YouTubeServices services = YouTubeServices();
