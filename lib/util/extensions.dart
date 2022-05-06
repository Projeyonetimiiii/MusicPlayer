import 'package:flutter/material.dart';
import 'package:onlinemusic/providers/data.dart';
import 'package:provider/provider.dart';

extension BuildContextExt on BuildContext {
  Future<T?> push<T>(Widget page) {
    return Navigator.push(this, MaterialPageRoute(builder: (_) => page));
  }

  Future<T?> pushAndRemoveUntil<T>(Widget page) {
    return Navigator.pushAndRemoveUntil(
      this,
      MaterialPageRoute(builder: (_) => page),
      (_) => false,
    );
  }

  MyData get myData => this.read<MyData>();
}
