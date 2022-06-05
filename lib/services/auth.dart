import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/models/request_model.dart';
import 'package:onlinemusic/models/usermodel.dart';
import 'package:onlinemusic/services/user_status_service.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/enums.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/util/helper_functions.dart';
import 'package:onlinemusic/views/message_screen/message_screen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _requestSubscription;

  static StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _resultSubscription;
  CollectionReference<Map<String, dynamic>> get usersReference =>
      _firestore.collection("Users");

  CollectionReference<Map<String, dynamic>> userRequestsHistoryReference(
      String id) {
    return usersReference.doc(id).collection("requestHistory");
  }

  DocumentReference<Map<String, dynamic>> userRequestReference(String id) {
    return usersReference.doc(id).collection("reguest").doc("request");
  }

  DocumentReference<Map<String, dynamic>> userRequestResultReference() {
    return usersReference
        .doc(_auth.currentUser!.uid)
        .collection("reguestResult")
        .doc("result");
  }

  DocumentReference<Map<String, dynamic>> userRequestResultReferenceFromId(
      String id) {
    return usersReference.doc(id).collection("reguestResult").doc("result");
  }

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
      if (userCredential.user != null) {
        listen();
      }
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
    stopListen();
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
        listen();
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
    userModel = userModel
      ..id = user.uid
      ..image = user.photoURL;
    await _firestore
        .collection("Users")
        .doc(user.uid)
        .set(userModel.toMap(), SetOptions(merge: true));

    return user;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStreamFromId(
      String id) {
    return usersReference.doc(id).snapshots();
  }

  Future<UserModel?> getUserFromId(String id) async {
    DocumentSnapshot<Map<String, dynamic>> userData =
        await usersReference.doc(id).get();
    UserModel? user;
    try {
      if (userData.data() != null) {
        user = UserModel.fromMap(userData.data()!);
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
    return user;
  }

  Future<void> sendMatchRequest(String userId) async {
    String curId = _auth.currentUser!.uid;
    await UserStatusService().updateConenctionType(ConnectionType.Connecting);
    await UserStatusService()
        .updateConenctionTypeFromId(userId, ConnectionType.Connecting);
    RequestModel requestModel = RequestModel(
        senderId: curId, receiverId: userId, type: RequestType.Waiting);
    await userRequestReference(userId).set(requestModel.toMap());
  }

  void listenRequestResult() {
    _resultSubscription = userRequestResultReference().snapshots().listen(
      (event) async {
        if (event.data() == null) return;
        RequestModel requestModel = RequestModel.fromMap(event.data()!);
        bool isDenied = requestModel.type == RequestType.Denied;
        bool isAccepted = requestModel.type == RequestType.Accepted;
        print("result: " + requestModel.toString());
        if (!isDenied && !isAccepted) {
          return;
        }
        UserModel? user = await getUserFromId(requestModel.receiverId);
        if (user != null) {
          BuildContext? context = MyApp.navigatorKey.currentContext;
          if (context != null) {
            await event.reference.delete();
            bool? res = await showDialog<bool>(
              context: context,
              builder: (_) {
                return AlertDialog(
                  title: Text("Eşleşme Sonucu"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(user.image!),
                        ),
                        title: Text(user.userName ?? "User"),
                        subtitle: Text(
                          user.bio ?? "Biografi",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text("Yukarıdaki kullanıcı eşleşme isteğinizi " +
                          (isDenied ? "reddetti" : "kabul etti")),
                    ],
                  ),
                  actions: [
                    if (isAccepted)
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: Text("Mesaj At"),
                      ),
                  ],
                );
              },
            );
            if (res == true) {
              context.push(MessageScreen());
            }
          }
        }
      },
    );
  }

  void listen() {
    print("Dinleme işlemi başladı");
    if (_auth.currentUser != null) {
      listenUserRequest();
      listenRequestResult();
    }
  }

  void stopListen() {
    print("Dinleme işlemi kapandı");
    _requestSubscription?.cancel();
    _resultSubscription?.cancel();
  }

  void listenUserRequest() {
    _requestSubscription = userRequestReference(_auth.currentUser!.uid)
        .snapshots()
        .listen((event) async {
      if (event.data() == null) return;
      RequestModel requestModel = RequestModel.fromMap(event.data()!);
      print("request: " + requestModel.toString());
      UserModel? user = await getUserFromId(requestModel.senderId);
      if (user != null) {
        BuildContext? context = MyApp.navigatorKey.currentContext;
        if (context != null) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) {
                return AlertDialog(
                  title: Text("Eşleşme İstegi"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(user.image!),
                        ),
                        title: Text(user.userName ?? "User"),
                        subtitle: Text(
                          user.bio ?? "Biografi",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text("Yukarıdaki kullanıcı sizinle eşleşmek istiyor"),
                    ],
                  ),
                  actions: [
                    TextButton(
                        onPressed: () async {
                          await userRequestResultReferenceFromId(
                                  requestModel.senderId)
                              .set((requestModel..type = RequestType.Accepted)
                                  .toMap());
                          UserStatusService service = UserStatusService();
                          service.connectUser(requestModel.senderId);
                          UserStatusService()
                              .updateConenctionType(ConnectionType.Ready);
                          UserStatusService().updateConenctionTypeFromId(
                              requestModel.senderId, ConnectionType.Ready);
                          event.reference.delete();
                          Navigator.pop(context);
                        },
                        child: Text("Eşleş")),
                    TextButton(
                        onPressed: () async {
                          await UserStatusService()
                              .updateConenctionType(ConnectionType.Ready);
                          await UserStatusService().updateConenctionTypeFromId(
                              requestModel.senderId, ConnectionType.Ready);
                          await event.reference.delete();
                          Navigator.pop(context);
                        },
                        child: Text("Eşleşme")),
                  ],
                );
              });
        }
      }
    });
  }
}
