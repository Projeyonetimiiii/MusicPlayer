import 'package:flutter/material.dart';
import 'package:on_video_query/on_video_query.dart';
import 'package:onlinemusic/util/extensions.dart';

import 'local_video_detail_page.dart';

class LocalVideosPage extends StatefulWidget {
  const LocalVideosPage({Key? key}) : super(key: key);

  @override
  State<LocalVideosPage> createState() => _LocalVideosPageState();
}

class _LocalVideosPageState extends State<LocalVideosPage> {
  List<FolderVideos> folders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getVideos();
  }

  getVideos() async {
    List<FolderVideos> folders = (await OnVideoQuery.getVideos) ?? [];
    setState(() {
      isLoading = false;
      this.folders = folders;
    });
  }

  @override
  void didUpdateWidget(covariant LocalVideosPage oldWidget) {
    getVideos();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Videolarım"),
      ),
      body: getBody(),
    );
  }

  Widget getBody() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    if (folders.isEmpty) {
      return Center(
        child: Text("Hiç Video Yok"),
      );
    }
    return GridView.count(
      crossAxisCount: 2,
      children: folders.map((e) {
        return Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: Colors.grey.shade300,
          ),
          child: InkWell(
            onTap: () async {
              context.push(
                VideosDetails(
                  folder: e,
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 100,
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          child: Text(
                            e.videos.length.toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(e.name),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
