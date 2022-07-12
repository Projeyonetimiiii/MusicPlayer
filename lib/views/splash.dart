import 'package:flutter/material.dart';
import 'package:onlinemusic/services/app_update_service.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/views/state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double textHeight = size.height * 0.1;
    return Material(
      color: Const.themeColor,
      child: Column(
        children: [
          SizedBox(
            height: size.height * 0.7,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.3, end: 1),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.elasticInOut,
              builder: (_, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(size.height),
                      child: Image.asset(
                        "assets/images/logo.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: textHeight,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: -1, end: 0),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.elasticInOut,
              builder: (_, value, child) {
                return Transform.translate(
                  offset: Offset(value * size.width, 0),
                  child: child,
                );
              },
              child: Center(
                child: Text(
                  "Müzik Player'a",
                  style: TextStyle(
                    fontSize: textHeight * 0.6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: textHeight,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 1, end: 0),
              onEnd: () {
                AppUpdateService.checkForUpdates();
                Navigator.pushAndRemoveUntil(
                  context,
                  FadePageTransition(StateScreen()),
                  (_) => false,
                );
              },
              duration: const Duration(milliseconds: 1600),
              curve: Curves.linear,
              builder: (_, value, child) {
                return Transform.translate(
                  offset: Offset(0, (size.width) * value),
                  child: child,
                );
              },
              child: Center(
                child: Text(
                  "Hoş Geldiniz",
                  style: TextStyle(
                    fontSize: textHeight * 0.5,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FadePageTransition extends PageRoute {
  Widget newPage;

  FadePageTransition(this.newPage);

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return FadeTransition(
      opacity: animation,
      child: newPage,
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);
}
