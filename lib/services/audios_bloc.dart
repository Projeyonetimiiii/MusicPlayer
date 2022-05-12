import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlinemusic/models/audio.dart';

class AudiosBloc {
  late final FirebaseFirestore _firestore;
  List<Audio> audioList = [];

  CollectionReference<Map<String, dynamic>> get audiosReference =>
      _firestore.collection("audios");

  AudiosBloc() {
    _firestore = FirebaseFirestore.instance;
  }

  void getAudiosMusic() async {
    await audiosReference.get().then((value) {
      audioList =
          value.docs.map((value) => Audio.fromMap(value.data())).toList();
    });
  }

  Stream<List<Audio>> getAudiosFromGenre(int genreId) async* {
    await for (var event in audiosReference
        .where(
          "genreIds",
          arrayContains: genreId,
        )
        .snapshots()) {
      List<Audio> audios = event.docs.map((e) {
        return Audio.fromMap(e.data());
      }).toList();
      yield audios;
    }
  }

  Future<String> saveImage(Uint8List? bytes) async {
    return "";
  }
}
