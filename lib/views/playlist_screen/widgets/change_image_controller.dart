import 'dart:async';

import 'package:flutter/cupertino.dart';

class ChangeImageController extends ChangeNotifier {
  ChangeImageController();

  Timer? timer;

  void startTimer() {
    timer = Timer.periodic(
      Duration(seconds: 10),
      (timer) {
        notifyListeners();
      },
    );
  }

  void stopTimer() {
    timer?.cancel();
  }
}
