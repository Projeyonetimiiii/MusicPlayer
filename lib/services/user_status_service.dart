import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onlinemusic/models/usermodel.dart';
import 'package:onlinemusic/util/enums.dart';

class UserStatusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateProfile(UserModel userModel) async {
    try {
      await _firestore
          .collection("Users")
          .doc(_auth.currentUser!.uid)
          .set(userModel.toMap(), SetOptions(merge: true));
    } catch (e) {
      print("hata ******************* " + e.toString());
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
      print("hata ******************* " + e.toString());
    }
  }

  Future<void> disconnectUser(String connectUserId) async {
    try {
      await _firestore.collection("Users").doc(_auth.currentUser!.uid).set({
        "connectedUserId": null,
      }, SetOptions(merge: true));
      await _firestore.collection("Users").doc(connectUserId).set({
        "connectedUserId": null,
      }, SetOptions(merge: true));
    } catch (e) {
      print("hata ******************* " + e.toString());
    }
  }

  Future<void> updateConenctionTypeFromId(
      String id, ConnectionType newType) async {
    try {
      await _firestore.collection("Users").doc(id).set({
        "connectionType": newType.index,
      }, SetOptions(merge: true));
    } catch (e) {
      print("hata ******************* " + e.toString());
    }
  }

  Future<void> updateConenctionType(ConnectionType newType) async {
    try {
      await _firestore.collection("Users").doc(_auth.currentUser!.uid).set({
        "connectionType": newType.index,
      }, SetOptions(merge: true));
    } catch (e) {
      print("hata ******************* " + e.toString());
    }
  }
}
