import 'package:audio_service/audio_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:onlinemusic/providers/data.dart';
import 'package:onlinemusic/services/auth.dart';
import 'package:onlinemusic/services/background_audio_handler.dart';
import 'package:onlinemusic/services/listening_song_service.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/widgets/app_lifecycle.dart';

import 'views/splash.dart';

Box<List<String>>? favoriteBox;
Box<String>? cacheBox;
late BackgroundAudioHandler handler;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initHive();
  cacheBox = await openBox<String>("cache");
  favoriteBox = await openBox<List<String>>("farovite");
  await initBackgroundService();
  AuthService().listen();
  runApp(
    MyApp(),
  );
}

Future<void> initBackgroundService() async {
  handler = await AudioService.init(
    builder: () => BackgroundAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelName: "Müzik",
      androidNotificationChannelDescription: "Müzik Bildirimi",
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyData>(
      create: (BuildContext context) {
        return MyData();
      },
      child: AppLifecycle(
        child: OverlaySupport.global(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            title: "online Music",
            color: Colors.black,
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.dark,
            home: SplashScreen(),
          ),
        ),
        changeLifecycle: (state) {
          if (state == AppLifecycleState.paused) {
            AuthService().stopListen();
            if (!handler.isPlaying) {
              listeningSongService.deleteUserIdFromLastListenedSongId();
            }
          }
          if (state == AppLifecycleState.resumed) {
            AuthService().listen();
            if (handler.mediaItem.value != null) {
              if (handler.mediaItem.value!.isOnline) {
                listeningSongService.listeningSong(handler.mediaItem.value!);
              }
            }
          }
        },
      ),
    );
  }
}

Future<Box<E>> openBox<E>(String s) async {
  return await Hive.openBox<E>(s);
}

Future<void> initHive() async {
  var appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);
}
