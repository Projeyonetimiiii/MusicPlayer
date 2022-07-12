import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/models/connected_controller.dart';
import 'package:onlinemusic/models/connected_song_model.dart';
import 'package:onlinemusic/models/usermodel.dart';
import 'package:onlinemusic/services/auth.dart';
import 'package:onlinemusic/services/messages_service.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/widgets/my_overlay_notification.dart';
import 'package:rxdart/rxdart.dart';

class ConnectedSongService {
  late final FirebaseFirestore _firestore;
  late final FirebaseAuth _auth;
  late final BehaviorSubject<ConnectedSongModel?> connectSongModel;
  late final BehaviorSubject<ConnectedController?> controller;

  bool get isAdmin {
    if (connectSongModel.value == null) {
      return true;
    } else {
      return connectSongModel.value!.isAdmin;
    }
  }

  bool get isConnectedSong {
    return connectSongModel.value != null;
  }

  static ConnectedSongService? _instance;

  String? userId;
  StreamSubscription? controllerSubscription;
  StreamSubscription? userSubscription;
  StreamSubscription? songSubscription;
  MediaItem? lastItem;

  CollectionReference<Map<String, dynamic>> get connectedSongReference =>
      _firestore.collection("connectedSongs");

  Stream<DocumentSnapshot<Map<String, dynamic>>>
      getConnectedSongStreamFromDocId(String docId) {
    return connectedSongReference.doc(docId).snapshots();
  }

  factory ConnectedSongService() {
    return _instance ??= ConnectedSongService._();
  }

  ConnectedSongService._() {
    connectSongModel = BehaviorSubject.seeded(null);
    controller = BehaviorSubject.seeded(null);
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;
  }

  Future<void> updateController(
      ConnectedController controller, String docId) async {
    connectedSongReference.doc(docId).set(
          controller.toMap(),
          SetOptions(merge: true),
        );
  }

  void startListen() {
    userSubscription =
        AuthService().getUserStreamFromId(_auth.currentUser!.uid).listen(
      (event) {
        if (event.data() != null) {
          UserModel user = UserModel.fromMap(event.data()!);
          if (user.connectedSongModel != null) {
            connectSongModel.add(user.connectedSongModel);
            if (user.connectedSongModel!.isAdmin) {
              _listenAdminController(user.connectedSongModel!.userId);
              _listenCurrentSong(user.connectedSongModel!.userId);
            } else {
              songSubscription?.cancel();
              _listenConnectedSong(user.connectedSongModel!.userId);
            }
          } else {
            if (connectSongModel.value != null) {
              showMessage(
                message: "Müziğin eşleşmesi bitirildi",
              );
              disconnectSong();
            }
          }
        }
      },
    );
  }

  void _listenAdminController(String uid) {
    String docId = messagesService.getDoc(_auth.currentUser!.uid, uid);
    controllerSubscription =
        getConnectedSongStreamFromDocId(docId).listen((event) {
      if (event.data() != null) {
        ConnectedController connectedController =
            ConnectedController.fromMap(event.data()!);
        controller.add(connectedController);
      }
    });
  }

  void stopListen() {
    userSubscription?.cancel();
    controllerSubscription?.cancel();
    songSubscription?.cancel();
    processSub?.cancel();
  }

  StreamSubscription? processSub;

  void _listenConnectedSong(String uid) {
    String docId = messagesService.getDoc(_auth.currentUser!.uid, uid);
    userId = uid;
    controllerSubscription =
        getConnectedSongStreamFromDocId(docId).listen((event) async {
      if (event.data() != null) {
        ConnectedController connectedController =
            ConnectedController.fromMap(event.data()!);
        if (lastItem?.id != connectedController.song.id) {
          if (connectedController.isReady == true) {
            lastItem = connectedController.song;
            await updateController(
                connectedController.copyWith(isReady: false), docId);
            if (appIsRunnig) {
              try {
                await handler.pause();
              } on Exception catch (_) {}
              showMyOverlayNotification(
                duration: Duration(seconds: 2),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    width: 45,
                    height: 45,
                    child: lastItem!.getImageWidget,
                  ),
                ),
                message: lastItem!.title + " adlı müziği hazırlıyorum",
              );
            }
            if (connectedController.queue.map((e) => e.toJson).join() !=
                handler.queue.value.map((e) => e.toJson).join()) {
              await handler.updateQueue(connectedController.queue);
            }
            await handler.playMediaItem(lastItem!);
            await handler.player.seek(connectedController.position);
            if (processSub == null) {
              processSub = handler.playbackState.listen(
                (value) async {
                  if (value.processingState == AudioProcessingState.ready) {
                    await updateController(
                      connectedController.copyWith(isReady: true),
                      docId,
                    );
                    processSub?.cancel();
                    processSub = null;
                  }
                },
              );
            }
          }
        }
        if (connectedController.isReady == true) {
          if ((connectedController.position.inSeconds -
                      handler.position.inSeconds)
                  .abs() >
              4) {
            await handler.player.seek(connectedController.position);
          }
          if (connectedController.isPlaying) {
            try {
              handler.play();
            } on Exception catch (_) {}
          } else {
            try {
              handler.pause();
            } on Exception catch (_) {}
          }
        } else {
          try {
            handler.pause();
          } on Exception catch (_) {}
        }
      } else {
        await event.reference.delete();
      }
    });
  }

  void disconnectSong({String? uid}) {
    String? uId = uid ?? userId;
    if (uId != null) {
      stopListen();
      lastItem = null;
      userId = null;
      String docId = messagesService.getDoc(_auth.currentUser!.uid, uId);
      try {
        connectedSongReference.doc(docId).delete();
      } on Exception catch (_) {}
      connectSongModel.add(null);
      controller.add(null);
    }
  }

  void connectSong(String uid) {
    if (handler.mediaItem.value != null) {
      try {
        handler.pause();
      } on Exception catch (_) {}
      String docId = messagesService.getDoc(_auth.currentUser!.uid, uid);
      ConnectedController connectedController = ConnectedController(
        position: handler.position,
        song: handler.mediaItem.value!,
        queue: handler.queue.value,
        isPlaying: false,
        isReady: true,
      );
      controller.add(connectedController);
      connectedSongReference.doc(docId).set(
            connectedController.toMap(),
          );
      startListen();
    }
  }

  void _listenCurrentSong(String uid) {
    String docId = messagesService.getDoc(_auth.currentUser!.uid, uid);
    userId = uid;
    songSubscription = handler.playbackState.listen(
      (value) {
        if (handler.mediaItem.value != null) {
          if (handler.mediaItem.value!.isOnline) {
            updateController(
              ConnectedController(
                position: value.position,
                song: handler.mediaItem.value!,
                isPlaying: value.playing,
                queue: handler.queue.value,
              ),
              docId,
            );
          }
        }
      },
    );
  }
}

ConnectedSongService connectedSongService = ConnectedSongService();
