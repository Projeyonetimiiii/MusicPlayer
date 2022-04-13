import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'blogs/data.dart';
import 'views/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyData>(create: (BuildContext context) { 
      return MyData();
     },
     child: MaterialApp(
       title: "online Music",
       color: Colors.black,
       debugShowCheckedModeBanner: false,
       themeMode: ThemeMode.dark,
       home: SplashScreen(),
     ),
    );
  }
}