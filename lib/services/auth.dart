import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onlinemusic/models/usermodel.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/helper_functions.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //giriş yap fonksiyonu
  Future<User?> signIn(
    String email,
    String password,
  ) async {
    bool isEmail = EmailValidator.validate(email);
    if (!isEmail) {
      showErrorNotification(
        description: "Lütfen doğru bir email girdiğinize emin olun",
      );
      return null;
    }
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      print(userCredential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Hata: " + e.code);
      if (e.code == "network-request-failed") {
        //! bağlantı hatası
        showErrorNotification(
          description: "Lütfen internet bağlantınızı kontol edin",
        );
        return null;
      }
      if (e.code == "user-not-found") {
        //! kayıtlı bir kullanıcı yok
        showErrorNotification(
          description: "Kayıtlı bir kullanıcı yok",
        );
        return null;
      }
      if (e.code == "wrong-password") {
        //! hatalı şifre
        showErrorNotification(
          description: "E-posta veya şifre hatalı",
        );
        return null;
      } else {
        showErrorNotification(
          description: "Hata oluştu, lütfen daha sonra tekrar dene",
        );
      }
      return null;
    }
  }

  //çıkış yap fonksiyonu
  signOut() async {
    return await _auth.signOut();
  }

  //kayıt ol fonksiyonu
  Future<User?> createPerson(UserModel userModel, String password) async {
    bool isEmail = EmailValidator.validate(userModel.email!);
    if (!isEmail) {
      showErrorNotification(
        description: "Lütfen doğru bir email girdiğinize emin olun",
      );
      return null;
    }
    UserCredential userCredential;
    try {
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: userModel.email!,
        password: password,
      );
      if (userCredential.user != null) {
        await userCredential.user!
            .updateDisplayName(userModel.userName ?? "User");
        await userCredential.user!.updatePhotoURL(
          Const.kDefaultProfilePicture,
        );
        print(userCredential.user);
      }
    } on FirebaseException catch (e) {
      if (e.code == "email-already-in-use") {
        showErrorNotification(
          description: "Email daha önceden kayıt edilmiş",
        );
      } else if (e.code == "weak-password") {
        showErrorNotification(
          description: "Şifre çok kısa ",
        );
      } else {
        showErrorNotification(
          description: "Hata oluştu, lütfen daha sonra tekrar dene",
        );
      }
      return null;
    }
    User? user = userCredential.user;
    if (user == null) return null;
    user = FirebaseAuth.instance.currentUser ?? user;
    await _firestore
        .collection("User")
        .doc(user.uid)
        .set({'userName': user.displayName, 'email': user.email});

    await _firestore.collection("UserProfile").doc(user.uid).set(
        (userModel
              ..id = user.uid
              ..image = user.photoURL)
            .toMap(),
        SetOptions(merge: true));

    return user;
  }
}
