import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/views/state.dart';

import 'home.dart';
import 'register_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => StateScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(),
            SizedBox(
              height: 20,
            ),
            Text("Açılıyor...")
          ],
        ),
      ),
    );
  }
}
