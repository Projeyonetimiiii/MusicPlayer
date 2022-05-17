import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  Future<bool> saveAudioToFirebase(Audio audio) async {
    try {
      audiosReference.add(audio.toMap());
      return true;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<List<Audio>> getMySharedAudios() async {
    String myId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot<Map<String, dynamic>> query = await audiosReference
        .where("idOfTheSharingUser", isEqualTo: myId)
        .get();
    return query.docs.map((e) => Audio.fromMap(e.data())).toList();
  }
}
