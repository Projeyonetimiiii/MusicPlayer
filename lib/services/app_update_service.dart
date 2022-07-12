import 'package:app_installer/app_installer.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/models/update_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

class AppUpdateService {
  static final double version = 1.3;
  static final String _baseUrl =
      "https://raw.githubusercontent.com/OrtakProje-1/app_versions/master/music_player/";
  static final String _lastVersionUrl = _baseUrl + "last_version.json";

  static Future<void> checkForUpdates() async {
    try {
      http.Response res = await http.get(Uri.parse(_lastVersionUrl));
      if (res.statusCode == 200) {
        UpdateModel model = UpdateModel.fromJson(res.body);
        if (version < model.version) {
          ApkInfo info = await _getApkInfo(model);
          bool? result = await _showUpdateDialog(model, info);
          if (result == true) {
            String path = await _getDownloadPath(model);
            String url = _getDownloadUrl(model, info);
            showDownloadingDialog(path, url);
          }
        }
      }
    } on Exception catch (e) {
      debugPrint("hata" + e.toString());
    }
  }

  static Future<ApkInfo> _getApkInfo(UpdateModel model) async {
    String abi = "universal";

    List? abis = await cacheBox!.get('supportedAbis') as List?;

    if (abis == null) {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      abis = androidDeviceInfo.supportedAbis;
      await cacheBox!.put('supportedAbis', abis);
    }

    if (abis.contains('arm64-v8a')) {
      abi = 'arm64-v8a';
    } else {
      if (abis.contains('armeabi-v7a')) {
        abi = 'armeabi-v7a';
      } else {
        abi = 'universal';
      }
    }

    ApkInfo? info;

    if (abi != "universal") {
      if (!model.apks.any((element) => element == abi)) {
        abi = "universal";
      }
    }

    info = model.apkInfos.firstWhere((element) => element.name == abi);
    // return _baseUrl + model.version.toString() + "/apks/$abi.apk";
    return info;
  }

  static String _getDownloadUrl(UpdateModel model, ApkInfo info) {
    return _baseUrl + model.version.toString() + "/apks/${info.name}.apk";
  }

  static Future<String> _getDownloadPath(UpdateModel model) async {
    String? path;
    List<String>? donwloadPath5 =
        (await getExternalStorageDirectories(type: StorageDirectory.downloads))
            ?.map((e) => e.path)
            .toList();
    path = donwloadPath5?.first;
    path ??= (await getTemporaryDirectory()).path;
    return path + "/Music-Player-v${model.version}.apk";
  }
}

Future<bool> startDownload(String path, String url, BehaviorSubject loading,
    {CancelToken? cancelToken}) async {
  Dio dio = Dio();
  try {
    Response res = await dio.download(
      url,
      path,
      cancelToken: cancelToken,
      onReceiveProgress: (rec, total) async {
        if (total != -1) {
          loading.add((rec / total * 100).clamp(0, 100));
          print((rec / total * 100).toStringAsFixed(0) + "%");
          if (loading.value == 100) {
            await AppInstaller.installApk(path);
          }
        }
      },
    );
    if (res.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } on Exception catch (_) {
    return false;
  }
}

void showDownloadingDialog(String path, String url) {
  showDialog(
    barrierDismissible: false,
    context: MyApp.navigatorKey.currentContext!,
    builder: (ctx) {
      CancelToken cancelToken = CancelToken();
      BehaviorSubject<double> loading = BehaviorSubject.seeded(0);
      bool isClosing = false;
      return FutureBuilder<bool>(
        future: startDownload(path, url, loading, cancelToken: cancelToken),
        builder: (context, snapshot) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.grey.shade200,
            title: Text(
                "İndirme ${snapshot.data == false ? "Hatası" : "Başladı"}"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (snapshot.data != true) ...[
                  LottieBuilder.asset("assets/lotties/downloading.json"),
                  StreamBuilder<double>(
                    stream: loading,
                    initialData: 0,
                    builder: (c, s) {
                      if (s.data == 100) {
                        if (!isClosing) {
                          isClosing = true;
                          Future.delayed(Duration(seconds: 3), () {
                            Navigator.pop(ctx);
                            loading.close();
                          });
                        }
                      }
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(s.data!.toInt().toString() + "%"),
                        ),
                      );
                    },
                  ),
                ],
                if (snapshot.data == false) Text("Beklenmeyen bir hata oluştu"),
              ],
            ),
            actions: [
              if (snapshot.data == false)
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx, false);
                  },
                  child: Text("Tamam"),
                ),
              if (snapshot.data == true)
                TextButton(
                  onPressed: () {
                    cancelToken.cancel();
                    Navigator.pop(ctx, false);
                  },
                  child: Text("İptal Et"),
                ),
            ],
          );
        },
      );
    },
  );
}

String _getTitle(UpdateModel model) {
  if (model.title != null && model.title!.isNotEmpty) return model.title!;
  return "Yeni Bir Güncelleme Mevcut " +
      ("v${AppUpdateService.version}" + " -> v" + model.version.toString());
}

Future<bool?> _showUpdateDialog(UpdateModel model, ApkInfo info) async {
  return showDialog<bool>(
    context: MyApp.navigatorKey.currentContext!,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.grey.shade200,
        title: Text(
          _getTitle(model),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Yapılan Değişiklikler:",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: model.changes.map(
                  (e) {
                    return Text(
                      "• " + e,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
            if (info.size != null && info.size!.isNotEmpty) ...[
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Tahmini İndirme Boyutu: " + info.size!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx, false);
            },
            child: Text("Güncelleme"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx, true);
            },
            child: Text("Güncelle"),
          ),
        ],
      );
    },
  );
}
