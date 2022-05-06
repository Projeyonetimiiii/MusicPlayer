import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:onlinemusic/models/media_reference.dart';

class StorageBlock {
  StorageBlock() {
    _storage = FirebaseStorage.instance;
    _reference = _storage.ref();
  }

  late Reference _reference;
  late FirebaseStorage _storage;

  Reference get reference => _reference;

  Reference get audiosRef {
    return reference.child("audio");
  }

  Future<MediaReference> uploadAudio({
    required File file,
    required String userUid,
    int index = 0,
    String? timeStamp,
    String? ext,
  }) async {
    ext = ext ?? fileExt(file.path);
    timeStamp = timeStamp ?? DateTime.now().millisecondsSinceEpoch.toString();
    String ref = "$timeStamp-$index.$ext";
    UploadTask task = audiosRef
        .child(userUid)
        .child(ref)
        .putFile(file, SettableMetadata(contentType: 'audio/$ext'));
    await task.whenComplete(() => null);
    String downloadURL = await task.snapshot.ref.getDownloadURL();
    return MediaReference(ref: ref, downloadURL: downloadURL);
  }

  static String fileExt(String name) {
    return name.split(".").last;
  }

  // ref = MediaReference deki ref
  Future<void> deleteAudio(String uid, String ref) async {
    await audiosRef.child(uid).child(ref).delete();
  }

  void dispose() {}



}
