import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onlinemusic/models/usermodel.dart';

class UserStatusService{
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

  
}