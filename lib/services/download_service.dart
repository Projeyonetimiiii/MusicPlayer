import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/adapter.dart';
import 'package:downloader/downloader.dart';
import 'package:http/http.dart' as http;
import 'package:audio_service/audio_service.dart';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/models/mp3_converter/convert_result.dart';
import 'package:onlinemusic/models/mp3_converter/donwload_type.dart';
import 'package:onlinemusic/models/mp3_converter/search_video.dart';
import 'package:onlinemusic/providers/ext_storage_provider.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/converter.dart';
import 'package:onlinemusic/util/enums.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/downloaded_screen.dart';
import 'package:onlinemusic/widgets/my_overlay_notification.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Download with ChangeNotifier {
  int? rememberOption;
  final ValueNotifier<bool> remember = ValueNotifier<bool>(false);
  double? progress = 0.0;
  String lastDownloadId = '';
  MediaItem? downloadingItem;
  bool isPreparing = false;

  List<String> downloadedSongIds = [];
  List<MediaItem> downloadQueue = [];

  Download() {
    downloadedSongIds = downloadsBox!.keys.map((e) => e.toString()).toList();
    actionListen();
  }

  bool isDownloaded(MediaItem item) {
    return downloadedSongIds.any((element) => element == item.id);
  }

  saveQueueToHive() async {
    await songsBox!
        .put("downloadQueue", downloadQueue.map((e) => e.toJson).toList());
  }

  Future<bool> addQueue(
    MediaItem item,
    BuildContext context, {
    bool isShowMessage = false,
  }) async {
    if (item.type.isVideo) {
      if (!downloadQueue.any((element) => element.id == item.id) &&
          item.id != downloadingItem?.id) {
        downloadQueue.add(item);
        print("item kuyruğa eklendi");
        if (downloadingItem == null && !isPreparing) {
          print(item.title + " indirmeye başlıyor");
          if (isShowMessage) {
            showMessage(
              message: "İndirmeye hazırlanılıyor",
            );
          }
          return prepareDownload(context, item);
        } else {
          if (isShowMessage) {
            showMessage(
              message: "${item.title} kuyruğa eklendi",
            );
          }
        }
      }
      saveQueueToHive();
    }
    return false;
  }

  void addAllQueue(
    List<MediaItem> items,
    BuildContext context, {
    bool showMsg = true,
    bool isTest = false,
  }) async {
    List<MediaItem> queue = items
        .where((element) =>
            !downloadQueue.any((element2) => element2.id == element.id))
        .toList();
    queue.removeWhere((element) => !element.isOnline);

    if (queue.isEmpty) {
      if (showMsg) {
        showMessage(
          message: "Bütün müzikler zaten kuyrukta",
        );
      }
      return;
    }

    List<MediaItem> downloadedItems = queue
        .where((element) =>
            downloadedSongIds.any((element2) => element2 == element.id))
        .toList();

    if (downloadedItems.isNotEmpty) {
      bool res = await showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            title: Text("Yeniden indirilsin mi?"),
            content: Text(
                "Önceden indirmiş olduğunuz ${downloadedItems.length} adet müziği yeniden indirmek için kuyruğa eklememi ister misiniz?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text("Hayır"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text("Evet"),
              ),
            ],
          );
        },
      );
      if (res == false) {
        queue.removeWhere((element) =>
            downloadedItems.any((element2) => element2.id == element.id));
      }
    }

    if (queue.isEmpty) {
      showMessage(
        message: "Kuyruğa eklenecek yeni müzik yok",
      );
      return;
    }

    if (downloadQueue.isEmpty && !isTest) {
      addQueue(items.first, context);
    }

    if (queue.isNotEmpty) {
      if (showMsg) {
        showMessage(
          message: "${queue.length} adet müzik indirme kuyruğuna eklendi",
        );
      }
      downloadQueue.addAll(queue);
      saveQueueToHive();
    }
  }

  void removeAllQueue(
    List<MediaItem> items, {
    bool showMsg = false,
  }) {
    downloadQueue.clear();
    if (downloadingItem != null) {
      downloadQueue.add(downloadingItem!);
    }
    showMessage(
      message: "Kuyruk temizlendi",
    );
    saveQueueToHive();
    notifyListeners();
  }

  void removeQueue(MediaItem item) {
    if (item.id == downloadingItem?.id) {
      return;
    }
    if (downloadQueue.any((element2) => element2.id == item.id)) {
      downloadQueue.removeWhere((element) => element.id == item.id);
    }
    saveQueueToHive();
  }

  Future<bool> prepareDownload(
    BuildContext context,
    MediaItem item, {
    bool createFolder = false,
    String? folderName,
  }) async {
    isPreparing = true;
    if (!Platform.isWindows) {
      PermissionStatus status = await Permission.storage.status;
      PermissionStatus mStatus = await Permission.manageExternalStorage.status;

      if (mStatus.isDenied) {
        await [
          Permission.manageExternalStorage,
        ].request();
        PermissionStatus mStatus =
            await Permission.manageExternalStorage.status;
        if (mStatus.isDenied) {
          showMessage(
            message: "İzin verilmedi",
          );
          isPreparing = false;
          notifyListeners();
          return false;
        }
      }
      if (status.isDenied) {
        await [
          Permission.storage,
          Permission.accessMediaLocation,
          Permission.mediaLibrary,
        ].request();
      }
      status = await Permission.storage.status;
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
    }
    final RegExp avoid = RegExp(r'[\.\\\*\:\"\?#/;\|]');

    String filename = '';
    filename = item.title + " - " + item.artist.toString();
    String dlPath = "";
    if (filename.length > 200) {
      final String temp = filename.substring(0, 200);
      final List tempList = temp.split(', ');
      tempList.removeLast();
      filename = tempList.join(', ');
    }
    DonwloadType type = await getMp3DownloadUrl(item.id);
    String ext = type.type.name;
    filename = '${filename.replaceAll(avoid, "").replaceAll("  ", " ")}.$ext';
    if (dlPath == '') {
      final String? temp =
          await ExtStorageProvider.getExtStorage(dirName: 'Music');
      dlPath = temp!;
    }
    if (item.type.isVideo) {
      dlPath = '$dlPath/YouTube';
      if (!await Directory(dlPath).exists()) {
        await Directory(dlPath).create();
      }
    }

    if (createFolder && folderName != null) {
      final String foldername = folderName.replaceAll(avoid, '');
      dlPath = '$dlPath/$foldername';
      if (!await Directory(dlPath).exists()) {
        await Directory(dlPath).create();
      }
    }

    final bool exists = await File('$dlPath/$filename').exists();
    if (exists) {
      if (remember.value == true && rememberOption != null) {
        switch (rememberOption) {
          case 0:
            lastDownloadId = item.id.toString();
            isPreparing = false;
            removeQueue(item);
            notifyListeners();
            return false;
          case 1:
            downloadSong(context, dlPath, filename, item, type);
            return true;
          case 2:
            while (await File('$dlPath/$filename').exists()) {
              filename = filename.replaceAll('.$ext', ' (1).$ext');
            }
            return true;
          default:
            lastDownloadId = item.id.toString();
            isPreparing = false;
            removeQueue(item);
            return false;
        }
      } else {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "Önceden İndirilmiş",
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '"${item.title}" tekrar indirmek ister misin?',
                    softWrap: true,
                  ),
                ],
              ),
              actions: [
                Column(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: remember,
                      builder: (
                        BuildContext context,
                        bool rememberValue,
                        Widget? child,
                      ) {
                        return CheckboxListTile(
                          title: Text("Seçimi hatırla"),
                          value: remember.value,
                          onChanged: (s) {
                            remember.value = s ?? false;
                          },
                        );
                      },
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              lastDownloadId = item.id.toString();

                              Navigator.pop(context);
                              rememberOption = 0;
                              notifyListeners();
                            },
                            child: Text(
                              "Hayır",
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              downloadsBox!.delete(item.id);
                              downloadSong(
                                  context, dlPath, filename, item, type);
                              rememberOption = 1;
                            },
                            child: Text("Üzerine Yaz"),
                          ),
                          const SizedBox(width: 5.0),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              int count = 1;
                              while (await File('$dlPath/$filename').exists()) {
                                if (count == 1) {
                                  filename = filename.replaceAll(
                                    '.$ext',
                                    '($count).$ext',
                                  );
                                } else {
                                  filename = filename.replaceAll(
                                    '(${count - 1}).$ext',
                                    '($count).$ext',
                                  );
                                }
                                count++;
                              }
                              rememberOption = 2;
                              downloadSong(
                                  context, dlPath, filename, item, type);
                            },
                            child: Text(
                              "Yeniden İndir",
                            ),
                          ),
                          const SizedBox(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
        if (rememberOption == 0) {
          isPreparing = false;
          downloadingItem = null;
          removeQueue(item);
          notifyListeners();
          return false;
        } else {
          return true;
        }
      }
    } else {
      downloadSong(context, dlPath, filename, item, type);
    }
    isPreparing = false;
    return true;
  }

  void nextDownloadItem(BuildContext context) {
    if (downloadQueue.isNotEmpty) {
      prepareDownload(context, downloadQueue.first);
    }
  }

  CancelToken? cancelToken;

  Future<void> downloadSong(
    BuildContext context,
    String? dlPath,
    String fileName,
    MediaItem item,
    DonwloadType type,
  ) async {
    downloadingItem = item;
    progress = null;
    notifyListeners();
    String ext = type.type.name;
    String? filepath;
    late String filepath2;
    String? appPath;
    String kUrl = type.url;
    final artname = fileName.replaceAll(".$ext", '.jpg');
    if (!Platform.isWindows) {
      appPath ??= (await getTemporaryDirectory()).path;
    } else {
      final Directory? temp = await getDownloadsDirectory();
      appPath = temp!.path;
    }
    cancelToken = CancelToken();
    try {
      await File('$dlPath/$fileName')
          .create(recursive: true)
          .then((value) => filepath = value.path);
      // print('created audio file');

      await File('$appPath/$artname')
          .create(recursive: true)
          .then((value) => filepath2 = value.path);
    } catch (e) {
      await [
        Permission.manageExternalStorage,
      ].request();
      await File('$dlPath/$fileName')
          .create(recursive: true)
          .then((value) => filepath = value.path);
      // print('created audio file');
      await File('$appPath/$artname')
          .create(recursive: true)
          .then((value) => filepath2 = value.path);
    }
    // debugPrint('Audio path $filepath');
    // debugPrint('Image path $filepath2');

    bool showNotification = true;

    Dio dio = Dio();
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
    dio.downloadUri(
      Uri.parse(kUrl),
      filepath,
      cancelToken: cancelToken,
      onReceiveProgress: (count, total) async {
        try {
          progress = count / total;
          if (showNotification || progress == 1) {
            print(progress);
            showProgressNotification(item.title, item, progress);
            showNotification = false;
            Future.delayed(
              Duration(milliseconds: 500),
              () {
                showNotification = true;
              },
            );
          }
          notifyListeners();
          if (progress == 1) {
            print("progress 100%");
            if (item.artUri != null) {
              print("indirme bitti resim inicek");
              final client = HttpClient();
              final HttpClientRequest request2 =
                  await client.getUrl(item.artUri!);
              final HttpClientResponse response2 = await request2.close();
              final bytes2 = await consolidateHttpClientResponseBytes(
                response2,
              );
              final File file2 = File(filepath2);

              await file2.writeAsBytes(bytes2);
            }

            final Tag tag = Tag(
              title: item.title,
              artist: item.artist,
              albumArtist: item.artist,
              artwork: filepath2,
              album: item.title,
              genre: item.genre,
              comment: 'FL • Apps',
            );
            if (Platform.isAndroid) {
              try {
                final tagger = Audiotagger();
                await tagger.writeTags(
                  path: filepath!,
                  tag: tag,
                );
              } catch (e) {
                log('Failed to edit tags');
              }
            }
            // debugPrint('Done');
            lastDownloadId = item.id.toString();
            progress = 0.0;
            MediaItem item2 = MediaItemConverter.jsonToMediaItem(item.toJson);
            int? id;
            if (filepath != null) {
              String? res = await Downloader().addToLibrary(filepath!);
              if (res != null) {
                id = int.tryParse(res.split("/").last);
                print("Müziğin id si = " + id.toString());
              }
              print("addToLibrary res= " + res.toString());
            }
            String json = (item2.copyWith.call(
              id: item2.id,
              artUri: Uri.file(filepath2),
              extras: item2.extras
                ?..addAll(
                  {
                    "newId": id,
                    "url": filepath,
                    "type": ModelType.SongModel.index,
                    "isOnline": false,
                    "downloadTime": DateTime.now().millisecondsSinceEpoch,
                  },
                ),
            )).toJson;
            downloadsBox!.put(item2.id, json);
            print(item2);
            downloadedSongIds.add(item.id);
            //? İNDİRME İŞLEMİ BİTTİ
            downloadingItem = null;
            removeQueue(item);
            nextDownloadItem(context);
            notifyListeners();
            showMessage(
              message: "İndirme işlemi bitti",
            );
          }
        } catch (e) {
          // print('Error: $e');
        }
      },
    );
  }

  void cancelDownload() {
    progress = null;
    cancelToken?.cancel();
    AwesomeNotifications()
        .cancel((downloadingItem?.duration ?? Duration.zero).inMilliseconds);
    downloadingItem = null;
    notifyListeners();
  }

  double getProgress(MediaItem item) {
    if (downloadingItem?.id == item.id) {
      return progress ?? 0;
    }
    return 0;
  }

  void actionListen() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (action) async {
        print(action);

        if (action.buttonKeyPressed == "cancel") {
          cancelDownload();
        }
        if (action.payload?["isDownload"] == "true") {
          if (!DonwnloadedScreen.isRunning) {
            BuildContext? ctx = MyApp.navigatorKey.currentContext;
            if (ctx != null) {
              ctx.push(DonwnloadedScreen());
            }
          }
        }
      },
    );
  }

  void showProgressNotification(
      String title, MediaItem item, double? progress) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        title: title,
        color: progress == null
            ? Const.kBackground
            : progress == 1
                ? Colors.green
                : Colors.blue,
        id: (item.duration ?? Duration.zero).inMilliseconds,
        showWhen: false,
        channelKey: "download_channel",
        notificationLayout: progress == 1
            ? NotificationLayout.Default
            : NotificationLayout.ProgressBar,
        summary: progress == null ? null : "${(progress * 100).toInt()}%",
        body: progress == null
            ? "İndirme işlemi başlatılıyor"
            : progress == 1
                ? "İndirme işlemi bitti"
                : "İndiriliyor",
        progress: progress == null ? null : (progress * 100).toInt(),
        payload: {
          "isDownload": (progress == 1).toString(),
        },
      ),
      actionButtons: [
        if (progress != null && progress != 1)
          NotificationActionButton(key: "cancel", label: "İptal Et"),
      ],
    );
  }

  Future<DonwloadType> getMp3DownloadUrl(String id) async {
    http.Response response = await http.post(
      Uri.parse("https://yt1s.com/api/ajaxSearch/index"),
      body: {
        "q": "https://www.youtube.com/watch?v=$id",
        "vt": "home",
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      SearchVideo video = SearchVideo.fromJson(map);
      if (video.links != null) {
        List<Link> mp3 = getLink(video, "mp3");
        if (mp3.isNotEmpty) {
          try {
            Data data = mp3.first.datas.first.datas;
            print(data.size);
            String? url = await mp3LinkConverter(data, id);
            if (url != null) {
              return DonwloadType(url: url, type: AudioType.mp3);
            }
          } on Exception catch (_) {}
        } else {
          List<Link> m4a = getLink(video, "m4a");
          if (m4a.isNotEmpty) {
            try {
              Data data = m4a.first.datas.first.datas;
              print(data.size);
              String? url = await mp3LinkConverter(data, id);
              if (url != null) {
                return DonwloadType(url: url, type: AudioType.m4a);
              }
            } on Exception catch (_) {}
          }
        }
      }
      print(video);
    }

    String url = await Const.getAudioUrlFromVideoId(id);
    return DonwloadType(url: url, type: AudioType.m4a);
  }

  Future<String?> mp3LinkConverter(Data data, String vid) async {
    if (data.k != null) {
      http.Response response = await http.post(
        Uri.parse("https://yt1s.com/api/ajaxConvert/convert"),
        body: {
          "vid": vid,
          "k": data.k!,
        },
      );
      if (response.statusCode == 200) {
        try {
          ConvertResult result =
              ConvertResult.fromJson(jsonDecode(response.body));
          if (result.status == "ok") {
            if (result.dlink != null && result.dlink!.isNotEmpty) {
              return result.dlink;
            }
          }
        } on Exception catch (_) {}
      }
    }
    return null;
  }

  List<Link> getLink(SearchVideo video, String title) {
    return video.links!.where((element) => element.title == title).toList();
  }
}

Download downloadService = Download();
                                                                            