
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onlinemusic/models/usermodel.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 
  //kayıt ol fonksiyonu
  Future<User?> createPerson(UserModel userModel, String password) async {
    var user = await _auth.createUserWithEmailAndPassword(
        email: userModel.email!, password: password);

    await _firestore
        .collection("User")
        .doc(user.user!.uid)
        .set({'userName': userModel.userName!, 'email': userModel.email!});

    await _firestore
        .collection("UserProfile")
        .doc(user.user!.uid)
        .set(userModel.toMap(), SetOptions(merge: true));

    return user.user;
  }
}
