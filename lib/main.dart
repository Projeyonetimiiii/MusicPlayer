import 'package:audio_service/audio_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:onlinemusic/providers/data.dart';
import 'package:onlinemusic/services/auth.dart';
import 'package:onlinemusic/services/background_audio_handler.dart';
import 'package:onlinemusic/services/connected_song_service.dart';
import 'package:onlinemusic/services/listening_song_service.dart';
import 'package:onlinemusic/services/user_status_service.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/widgets/app_lifecycle.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'views/splash.dart';

Box<List<String>>? songsBox;
Box<String>? cacheBox;
late BackgroundAudioHandler handler;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initHive();
  cacheBox = await openBox<String>("cache");
  songsBox = await openBox<List<String>>("songs");
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
      androidNotificationIcon: "drawable/ic_notification",
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
            title: "Music Player",
            color: Const.kBackground,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale("tr")],
            locale: Locale("tr"),
            theme: ThemeData.light().copyWith(
              brightness: Brightness.light,
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: Const.kBackground,
                selectionHandleColor: Const.kBackground,
                selectionColor: Const.kBackground.withOpacity(0.1),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: Const.kBackground,
                ),
              ),
              scaffoldBackgroundColor: Colors.grey.shade200,
              appBarTheme: AppBarTheme(
                elevation: 0,
                backgroundColor: Const.kBackground,
                systemOverlayStyle: SystemUiOverlayStyle.light,
                toolbarTextStyle:
                    TextTheme().bodyText2?.copyWith(color: Colors.white),
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
                iconTheme: IconThemeData(
                  color: Colors.white,
                ),
              ),
            ),
            home: SplashScreen(),
          ),
        ),
        changeLifecycle: (state) {
          if (state == AppLifecycleState.paused) {
            appIsRunnig = false;
            AuthService().stopListen();
            if (!handler.isPlaying) {
              listeningSongService.deleteUserIdFromLastListenedSongId();
              if (connectedSongService.userId != null) {
                UserStatusService()
                    .disconnectUserSong(connectedSongService.userId!);
              }
            }
          }
          if (state == AppLifecycleState.resumed) {
            appIsRunnig = true;
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

bool appIsRunnig = true;

Future<Box<E>> openBox<E>(String s) async {
  return await Hive.openBox<E>(s);
}

Future<void> initHive() async {
  var appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);
}
