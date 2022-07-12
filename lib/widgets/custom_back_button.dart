import 'package:flutter/material.dart';
import 'package:onlinemusic/util/const.dart';

class CustomBackButton extends StatelessWidget {
  final Color color;
  const CustomBackButton({Key? key, this.color = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.maybePop(context);
      },
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: Const.contrainsColor,
      ),
    );
  }
}
