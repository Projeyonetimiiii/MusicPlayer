
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onlinemusic/models/usermodel.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //giriş yap fonksiyonu
  Future<User?> signIn(String email, String password) async {
    var user = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return user.user;
  }

  //çıkış yap fonksiyonu
  signOut() async {
    return await _auth.signOut();
  }

 
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
