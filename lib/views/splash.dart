import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration(seconds: 2),
      () {
        context.pushAndRemoveUntil(StateScreen());
      },
    );
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
