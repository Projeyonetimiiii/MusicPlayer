import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:on_video_query/on_video_query.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/video_player_screen.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../util/const.dart';

class VideosDetails extends StatefulWidget {
  final FolderVideos folder;
  VideosDetails({
    Key? key,
    required this.folder,
  }) : super(key: key);

  @override
  State<VideosDetails> createState() => _VideosDetailsState();
}

class _VideosDetailsState extends State<VideosDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
      ),
      body: ListView(
        children: widget.folder.videos.map(
          (e) {
            return InkWell(
              onTap: () {
                context.push(
                  VideoPlayerScreen(isLocal: true, url: e.path),
                );
              },
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: SizedBox(
                    height: 100,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: getVideoImage(e.path),
                    ),
                  ),
                ),
                title: Text(
                  e.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                subtitle: Text(
                  e.path,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                trailing: Text(Const.getDurationString(
                    Duration(milliseconds: e.duration))),
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  FutureBuilder getVideoImage(String videoPath) {
    return FutureBuilder<Uint8List?>(
      future: VideoThumbnail.thumbnailData(
        video: videoPath,
        quality: 25,
      ),
      builder: (c, snap) {
        if (!snap.hasData) {
          return Container(
            color: Colors.grey.shade200,
          );
        }
        return Image.memory(
          snap.data!,
          fit: BoxFit.cover,
        );
      },
    );
  }
}
