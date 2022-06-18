import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/models/request_model.dart';
import 'package:onlinemusic/models/usermodel.dart';
import 'package:onlinemusic/services/audios_bloc.dart';
import 'package:onlinemusic/services/connected_song_service.dart';
import 'package:onlinemusic/services/user_status_service.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/enums.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/util/helper_functions.dart';
import 'package:onlinemusic/widgets/my_overlay_notification.dart';
import 'package:rxdart/rxdart.dart';

import '../views/chat/messages/message_screen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _requestSubscription;
  StreamSubscription? _resultSubscription;
  StreamSubscription? currentUserSubscription;

  late UserStatusService statusService;

  late BehaviorSubject<UserModel?> currentUser;

  static AuthService? _instance;

  factory AuthService() {
    return _instance ??= AuthService._();
  }

  AuthService._() {
    statusService = UserStatusService();
    currentUser = BehaviorSubject.seeded(null);
  }

  bool get isAdmin => currentUser.value?.isAdmin == true;

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
    await _auth.signOut();
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

  Future<void> sendUserMatchRequest(String userId) async {
    String curId = _auth.currentUser!.uid;
    await UserStatusService().updateConenctionType(ConnectionType.Connecting);
    await UserStatusService()
        .updateConenctionTypeFromId(userId, ConnectionType.Connecting);
    RequestModel requestModel = RequestModel(
      senderId: curId,
      receiverId: userId,
      requestType: RequestType.User,
      resultType: ResultType.Waiting,
    );
    await userRequestReference(userId).set(requestModel.toMap());
    showMyOverlayNotification(
      duration: Duration(seconds: 2),
      message: "İstek gönderildi",
      isDismissible: true,
    );
  }

  Future<void> sendSongMatchRequest(String userId) async {
    String curId = _auth.currentUser!.uid;
    RequestModel requestModel = RequestModel(
      senderId: curId,
      receiverId: userId,
      requestType: RequestType.Song,
      resultType: ResultType.Waiting,
    );
    await userRequestReference(userId).set(requestModel.toMap());
    showMyOverlayNotification(
      duration: Duration(seconds: 2),
      message: "İstek gönderildi",
      isDismissible: true,
    );
  }

  bool showingResult = false;

  void listenRequestResult() {
    _resultSubscription = userRequestResultReference().snapshots().listen(
      (event) async {
        if (event.data() == null) {
          await event.reference.delete();
          return;
        }
        RequestModel requestModel = RequestModel.fromMap(event.data()!);
        bool isDenied = requestModel.resultType == ResultType.Denied;
        bool isAccepted = requestModel.resultType == ResultType.Accepted;
        await event.reference.delete();
        if (!isDenied && !isAccepted) {
          return;
        }
        if (showingResult) return;
        showingResult = true;
        UserModel? user = await getUserFromId(requestModel.receiverId);
        if (user != null) {
          BuildContext? context = MyApp.navigatorKey.currentContext;
          if (!requestModel.requestType.isUser) {
            if (requestModel.resultType == ResultType.Accepted) {
              connectedSongService.connectSong(requestModel.receiverId);
            }
          }
          Vibrate.vibrate();

          // showingResult 5 saniye sonra true ise false yap, kullanıcı dismissible yaparsa showingResult değeri true kalır
          Future.delayed(
            Duration(seconds: 5),
            () {
              if (showingResult) {
                showingResult = false;
              }
            },
          );
          showMyOverlayNotification(
            isDismissible: true,
            duration: Duration(seconds: 5),
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: CachedNetworkImageProvider(user.image!),
            ),
            message: (user.userName ?? "user") +
                " eşleşme isteğinizi " +
                (isDenied ? "reddetti" : "kabul etti"),
            onFinish: () {
              showingResult = false;
            },
            actionsBuilder: (entry) {
              if (!isDenied &&
                  context != null &&
                  requestModel.requestType == RequestType.User) {
                return [
                  TextButton(
                      onPressed: () {
                        if (entry != null) {
                          entry.dismiss();
                        }
                        showingResult = false;
                        context.push(MessagesScreen(
                          user: user,
                        ));
                      },
                      child: Text("Mesaj At")),
                ];
              }
              return null;
            },
          );
        } else {
          showingResult = false;
        }
      },
    );
  }

  void listenCurrentUser() {
    currentUserSubscription =
        getUserStreamFromId(FirebaseAuth.instance.currentUser!.uid)
            .listen((event) {
      if (event.data() != null) {
        UserModel user = UserModel.fromMap(event.data()!);
        if (user.connectedUserId == null &&
            currentUser.value?.connectedUserId != null) {
          showMyOverlayNotification(
            duration: Duration(seconds: 2),
            message: "Kullanıcı eşleşme bitirildi",
            isDismissible: true,
          );
        }
        currentUser.add(user);
      }
    });
  }

  void listen() {
    if (_auth.currentUser != null) {
      listenUserRequest();
      listenRequestResult();
      statusService.userConnectStatus(true);
      statusService.listenBlockedUsers();
      listenCurrentUser();
      AudiosBloc().listenAudios();
    }
  }

  void stopListen() {
    _requestSubscription?.cancel();
    _resultSubscription?.cancel();
    statusService.userConnectStatus(false);
    statusService.stopListenBlockedUsers();
    currentUserSubscription?.cancel();
    AudiosBloc().stopListen();
  }

  bool showingRequest = false;

  void listenUserRequest() {
    _requestSubscription =
        userRequestReference(_auth.currentUser!.uid).snapshots().listen(
      (event) async {
        if (event.data() == null) {
          await event.reference.delete();
          return;
        }
        RequestModel requestModel = RequestModel.fromMap(event.data()!);
        await event.reference.delete();

        if (showingRequest) return;

        showingRequest = true;
        UserModel? user = await getUserFromId(requestModel.senderId);
        if (user != null) {
          Vibrate.vibrate();
          showMyOverlayNotification(
            isDismissible: false,
            duration: Duration(seconds: 10),
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: CachedNetworkImageProvider(user.image!),
            ),
            message: (user.userName ?? "user") +
                _getRequestType(requestModel.requestType),
            actionsBuilder: (entry) {
              return [
                TextButton(
                  onPressed: () async {
                    if (entry != null) {
                      entry.dismiss();
                    }
                    await userRequestResultReferenceFromId(
                            requestModel.senderId)
                        .set((requestModel..resultType = ResultType.Accepted)
                            .toMap());
                    UserStatusService service = UserStatusService();
                    if (requestModel.requestType.isUser) {
                      await service.connectUser(requestModel.senderId);
                      await service
                          .updateConenctionType(ConnectionType.Connected);
                      await service.updateConenctionTypeFromId(
                          requestModel.senderId, ConnectionType.Connected);
                    } else {
                      await service.connectUserSong(requestModel.senderId);
                    }
                    showingRequest = false;
                  },
                  child: Text("Kabul Et"),
                ),
                TextButton(
                  onPressed: () async {
                    if (entry != null) {
                      entry.dismiss();
                    }
                    await userRequestResultReferenceFromId(
                            requestModel.senderId)
                        .set((requestModel..resultType = ResultType.Denied)
                            .toMap());
                    if (requestModel.requestType.isUser) {
                      await UserStatusService()
                          .updateConenctionType(ConnectionType.Ready);
                      await UserStatusService().updateConenctionTypeFromId(
                          requestModel.senderId, ConnectionType.Ready);
                    }
                    showingRequest = false;
                  },
                  child: Text("Reddet"),
                ),
              ];
            },
            onFinish: () async {
              await userRequestResultReferenceFromId(requestModel.senderId)
                  .set((requestModel..resultType = ResultType.Denied).toMap());
              if (requestModel.requestType.isUser) {
                await UserStatusService()
                    .updateConenctionType(ConnectionType.Ready);
                await UserStatusService().updateConenctionTypeFromId(
                    requestModel.senderId, ConnectionType.Ready);
              }
              showingRequest = false;
            },
          );
        } else {
          showingRequest = false;
        }
      },
    );
  }

  String _getRequestType(RequestType requestType) {
    if (requestType == RequestType.User) {
      return " size bir eşleşme isteği gönderdi";
    } else {
      return " müziğini sizinle eşleştirmek istiyor";
    }
  }
}
