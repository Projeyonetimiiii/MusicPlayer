import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/models/audio.dart';
import 'package:rxdart/rxdart.dart';

class AudiosBloc {
  late final FirebaseFirestore _firestore;
  late final BehaviorSubject<List<Audio>> audiosSubject;

  List<Audio> get audioList => audiosSubject.value;

  StreamSubscription? streamSubscription;
  static AudiosBloc? _instance;

  CollectionReference<Map<String, dynamic>> get audiosReference =>
      _firestore.collection("audios");

  factory AudiosBloc() {
    return _instance ??= AudiosBloc._();
  }

  AudiosBloc._() {
    _firestore = FirebaseFirestore.instance;
    audiosSubject = BehaviorSubject.seeded([]);
  }

  void listenAudios() async {
    streamSubscription = audiosReference.snapshots().listen((value) {
      audiosSubject
          .add(value.docs.map((value) => Audio.fromMap(value.data())).toList());
    });
  }

  void stopListen() {
    streamSubscription?.cancel();
  }

  List<Audio> getAudiosFromGenreId(int genreId) {
    return audioList
        .where(
            (element) => element.genreIds.any((element) => element == genreId))
        .toList();
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
