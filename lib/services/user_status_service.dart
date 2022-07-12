import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onlinemusic/models/blocked_details.dart';
import 'package:onlinemusic/models/connected_song_model.dart';
import 'package:onlinemusic/models/usermodel.dart';
import 'package:onlinemusic/services/connected_song_service.dart';
import 'package:onlinemusic/util/enums.dart';
import 'package:rxdart/rxdart.dart';

class UserStatusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late BehaviorSubject<List<BlockedDetails>> blockedUsers;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      blockedUserSubscription;

  static UserStatusService? _instance;

  factory UserStatusService() {
    return _instance ??= UserStatusService._();
  }

  UserStatusService._() {
    init();
  }

  void init() {
    blockedUsers = BehaviorSubject.seeded([]);
  }

  DocumentReference<Map<String, dynamic>> queryFromUid(String? uid) =>
      _firestore.collection("Users").doc(uid);

  Stream<QuerySnapshot<Map<String, dynamic>>> streamBlockedUsers(String uid) =>
      queryFromUid(uid).collection("blockedUsers").snapshots();

  CollectionReference<Map<String, dynamic>> blockedUsersCollection(
          String? uid) =>
      queryFromUid(uid).collection("blockedUsers");

  void stopListenBlockedUsers() {
    blockedUserSubscription?.cancel();
  }

  Future<void> listenBlockedUsers() async {
    blockedUserSubscription =
        streamBlockedUsers(_auth.currentUser!.uid).listen((e) {
      List<BlockedDetails> usersUid =
          e.docs.map((e) => BlockedDetails.fromMap(e.data())).toList();
      blockedUsers.add(usersUid);
    });
  }

  Future<void> changeBlockedUser(UserModel my, String blockedUid) async {
    if (!blockedUsers.value.contains(blockedUid)) {
      await addNewBlockedUser(blockedUid);
    } else {
      await deleteBlockedUser(blockedUid);
    }
  }

  Future<void> addNewBlockedUser(String blockedUid) async {
    await blockedUsersCollection(_auth.currentUser!.uid)
        .doc(blockedUid)
        .set(BlockedDetails(
          blockedTime: DateTime.now(),
          blockedUid: blockedUid,
        ).toMap());
  }

  Future<void> deleteBlockedUser(String deleteBlockedUid) async {
    await blockedUsersCollection(_auth.currentUser!.uid)
        .doc(deleteBlockedUid)
        .delete();
  }

  Future<void> updateProfile(UserModel userModel) async {
    try {
      await _firestore
          .collection("Users")
          .doc(userModel.id)
          .set(userModel.toMap(), SetOptions(merge: true));
    } catch (e) {
      print("hata " + e.toString());
    }
  }

  Future<void> connectUser(String connectUserId) async {
    try {
      await _firestore.collection("Users").doc(_auth.currentUser!.uid).set({
        "connectedUserId": connectUserId,
      }, SetOptions(merge: true));
      await _firestore.collection("Users").doc(connectUserId).set({
        "connectedUserId": _auth.currentUser!.uid,
      }, SetOptions(merge: true));
    } catch (e) {
      print("hata " + e.toString());
    }
  }

  Future<void> disconnectUser(String connectUserId) async {
    try {
      await _firestore.collection("Users").doc(_auth.currentUser!.uid).set({
        "connectedUserId": null,
        "connectionType": ConnectionType.Ready.index,
      }, SetOptions(merge: true));
      await _firestore.collection("Users").doc(connectUserId).set({
        "connectedUserId": null,
        "connectionType": ConnectionType.Ready.index,
      }, SetOptions(merge: true));
      connectedSongService.disconnectSong();
    } catch (e) {
      print("hata " + e.toString());
    }
  }

  Future<void> connectUserSong(String connectedSongUserId) async {
    try {
      await _firestore.collection("Users").doc(_auth.currentUser!.uid).set({
        "connectedSongModel":
            ConnectedSongModel(isAdmin: false, userId: connectedSongUserId)
                .toMap(),
      }, SetOptions(merge: true));
      await _firestore.collection("Users").doc(connectedSongUserId).set({
        "connectedSongModel":
            ConnectedSongModel(isAdmin: true, userId: _auth.currentUser!.uid)
                .toMap(),
      }, SetOptions(merge: true));
      connectedSongService.startListen();
    } catch (e) {
      print("hata  " + e.toString());
    }
  }

  Future<void> disconnectUserSong(String connectedSongUserId) async {
    try {
      if (_auth.currentUser != null) {
        await _firestore.collection("Users").doc(_auth.currentUser!.uid).set({
          "connectedSongModel": null,
        }, SetOptions(merge: true));
        await _firestore.collection("Users").doc(connectedSongUserId).set({
          "connectedSongModel": null,
        }, SetOptions(merge: true));
        connectedSongService.disconnectSong(uid: connectedSongUserId);
      }
    } catch (e) {
      print("hata  " + e.toString());
    }
  }

  Future<void> userConnectStatus(bool isOnline) async {
    try {
      if (_auth.currentUser != null) {
        await _firestore.collection("Users").doc(_auth.currentUser!.uid).set({
          "isOnline": isOnline,
          if (!isOnline) "lastSeen": DateTime.now().millisecondsSinceEpoch,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print("hata  " + e.toString());
    }
  }

  Future<void> updateConenctionTypeFromId(
      String id, ConnectionType newType) async {
    try {
      await _firestore.collection("Users").doc(id).set({
        "connectionType": newType.index,
      }, SetOptions(merge: true));
    } catch (e) {
      print("hata  " + e.toString());
    }
  }

  Future<void> updateConenctionType(ConnectionType newType) async {
    try {
      await _firestore.collection("Users").doc(_auth.currentUser!.uid).set({
        "connectionType": newType.index,
      }, SetOptions(merge: true));
    } catch (e) {
      print("hata  " + e.toString());
    }
  }
}
