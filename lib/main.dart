import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/providers/data.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

import 'views/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyData>(
      create: (BuildContext context) {
        return MyData();
      },
      child: OverlaySupport.global(
        child: MaterialApp(
          title: "online Music",
          color: Colors.black,
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.dark,
          home: SplashScreen(),
        ),
      ),
    );
  }
}
