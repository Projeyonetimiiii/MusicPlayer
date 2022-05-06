import 'package:flutter/material.dart';
import 'package:onlinemusic/services/storage_bloc.dart';

class MyData extends ChangeNotifier {
  MyData() {
    _storageBlock = StorageBlock();
  }

  late StorageBlock _storageBlock;

  StorageBlock get sB => _storageBlock;
}
