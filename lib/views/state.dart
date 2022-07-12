import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/views/auth/login_screen.dart';

import 'root_app.dart';

class StateScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return ThemeListener(
      builder: (c) {
        if (_auth.currentUser == null) {
          return LoginScreen();
        } else {
          return RootApp();
        }
      },
    );
  }
}
