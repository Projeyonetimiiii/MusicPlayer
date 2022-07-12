import 'package:audio_service/audio_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:onlinemusic/providers/data.dart';
import 'package:onlinemusic/services/auth.dart';
import 'package:onlinemusic/services/background_audio_handler.dart';
import 'package:onlinemusic/services/connected_song_service.dart';
import 'package:onlinemusic/services/listening_song_service.dart';
import 'package:onlinemusic/services/theme_service.dart';
import 'package:onlinemusic/services/user_status_service.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/widgets/app_lifecycle.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'views/splash.dart';

Box<List<String>>? songsBox;
Box<List<String>>? playlistsBox;
Box? cacheBox;
Box? downloadsBox;
late BackgroundAudioHandler handler;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
    ],
  );
  await Firebase.initializeApp();
  await initHive();
  awesomeNotificationInitialize();
  cacheBox = await openBox("cache");
  downloadsBox = await openBox("downloads");
  playlistsBox = await openBox("playlistsBox");
  songsBox = await openBox<List<String>>("songs");
  await initBackgroundService();
  AuthService().listen();
  runApp(
    MyApp(),
  );
}

Future<void> awesomeNotificationInitialize() async {
  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
    'resource://drawable/download',
    [
      NotificationChannel(
        importance: NotificationImportance.Min,
        enableVibration: false,
        channelGroupKey: 'download_channel_group',
        channelKey: 'download_channel',
        channelName: 'İndirme Bildirimi',
        channelDescription: 'Müzik indirmede kullanılan bildirim',
        defaultColor: Const.kBackground,
        ledColor: Colors.white,
      )
    ],
    debug: kDebugMode,
  );
}

Future<void> initBackgroundService() async {
  handler = await AudioService.init(
    builder: () => BackgroundAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationIcon: "drawable/audio",
      androidNotificationChannelName: "Müzik",
      androidNotificationChannelDescription: "Müzik Bildirimi",
    ),
  );
}

class MyApp extends StatefulWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeService service = ThemeService();
  @override
  void initState() {
    super.initState();
    service.addListener(themeListener);
  }

  void themeListener() {
    setState(() {});
  }

  @override
  void dispose() {
    service.removeListener(themeListener);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyData>(
      create: (BuildContext context) {
        return MyData();
      },
      child: AppLifecycle(
        child: OverlaySupport.global(
          child: MaterialApp(
            navigatorKey: MyApp.navigatorKey,
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
            theme: service.light,
            darkTheme: service.dark,
            themeMode: service.themeMode,
            home: SplashScreen(),
          ),
        ),
        changeLifecycle: (state) {
          if (state == AppLifecycleState.paused) {
            appIsRunnig = false;
            AuthService().stopListen();
            if (connectedSongService.isAdmin) {
              if (!handler.isPlaying) {
                listeningSongService.deleteUserIdFromLastListenedSongId();
                if (connectedSongService.userId != null) {
                  UserStatusService().disconnectUserSong(
                    connectedSongService.userId!,
                  );
                }
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

typedef ThemeBuilder = Widget Function(ThemeMode);

class ThemeListener extends StatefulWidget {
  final ThemeBuilder builder;
  ThemeListener({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  State<ThemeListener> createState() => _ThemeListenerState();
}

class _ThemeListenerState extends State<ThemeListener> {
  ThemeService service = ThemeService();
  @override
  void initState() {
    service.addListener(themeListener);
    super.initState();
  }

  void themeListener() {
    setState(() {});
  }

  @override
  void dispose() {
    service.removeListener(themeListener);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(service.themeMode);
  }
}
