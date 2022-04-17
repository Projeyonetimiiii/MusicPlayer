import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/views/login_screen.dart';

import 'home.dart';

class StateScreen extends StatelessWidget {

   final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser == null) {
      return LoginScreen();
    } else {
      return HomePage();
    }
  }
}