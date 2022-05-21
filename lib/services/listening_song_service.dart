import 'package:audio_service/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/util/extensions.dart';

class ListeningSongService {
  late final FirebaseFirestore _firestore;

  static ListeningSongService? _instance;

  CollectionReference<Map<String, dynamic>> get listeningReference =>
      _firestore.collection("listening");

  factory ListeningSongService() {
    return _instance ??= ListeningSongService._();
  }

  ListeningSongService._() {
    _firestore = FirebaseFirestore.instance;
  }

  Future<void> listeningSong(MediaItem song) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await deleteUserIdFromLastListenedSongId(listeninSongId: song.id);
    await listeningReference.doc(song.id).set(song.toMap);
    await listeningReference.doc(song.id).collection("userIds").doc(userId).set(
      {"userId": userId},
      SetOptions(merge: true),
    );
  }

  Future<void> deleteUserIdFromLastListenedSongId(
      {String? listeninSongId}) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String? lastListenedSongId = cacheBox!.get("lastListenedSong");
    if (lastListenedSongId != null) {
      try {
        await listeningReference
            .doc(lastListenedSongId)
            .collection("userIds")
            .doc(userId)
            .delete();
        cacheBox!.delete("lastListenedSong");
      } on Exception catch (e) {
        debugPrint(e.toString());
      }
    }
    if (listeninSongId != null) {
      cacheBox!.put("lastListenedSong", listeninSongId);
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getListenersFrom(String songId) {
    return listeningReference.doc(songId).collection("userIds").get();
  }
}

ListeningSongService listeningSongService = ListeningSongService();
