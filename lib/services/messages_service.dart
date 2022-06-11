import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlinemusic/services/storage_bloc.dart';
import 'package:onlinemusic/util/enums.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/chat/models/chat.dart';
import 'package:onlinemusic/views/chat/models/chat_message.dart';
import 'package:rxdart/rxdart.dart';

class MessagesService {
  static MessagesService? _instance;

  User get currentUser => FirebaseAuth.instance.currentUser!;

  static MessagesService get instance {
    return MessagesService();
  }

  factory MessagesService() {
    return _instance ??= MessagesService._();
  }
  MessagesService._() {
    init();
  }

  FirebaseFirestore? _firestore;
  BehaviorSubject<List<Chat>>? lastMessagesStream;
  StreamSubscription? lastMessagesSubscription;

  init() {
    _firestore = FirebaseFirestore.instance;
    lastMessagesStream = BehaviorSubject.seeded([]);
    fetchLastMessages(FirebaseAuth.instance.currentUser!.uid);
  }

  clearData() {
    lastMessagesStream!.add([]);
    lastMessagesSubscription?.cancel();
  }

  Future<void> fetchLastMessages(String uid) async {
    print("fetch last message");
    lastMessagesSubscription = getLastMessagesStream(uid).listen((event) {
      print(event);
      List<Chat> lastMessages =
          event.docs.map((e) => Chat.fromMap(e.data())).toList();
      lastMessagesStream!.add(lastMessages);
    });
  }

  CollectionReference<Map<String, dynamic>> get messagesReference =>
      _firestore!.collection("Messages");
  CollectionReference<Map<String, dynamic>> messagesColReference(
          String docId) =>
      messagesReference.doc(docId).collection("messages");

  Stream<QuerySnapshot<Map<String, dynamic>>> getSortedMessageStream(
      String uid1, String uid2) {
    String reference = getDoc(uid1, uid2);
    return messagesReference
        .doc(reference)
        .collection("messages")
        .orderBy("messageTime", descending: true)
        .snapshots();
  }

  Future<void> deleteMessage(
      String recUid, ChatMessage message, BuildContext context) async {
    await _deleteMedia(message, context);
    await messagesColReference(getDoc(currentUser.uid, recUid))
        .doc(message.senderId! + message.messageTime.toString())
        .delete();
  }

  Future<void> _deleteMedia(ChatMessage mes, BuildContext context) async {
    await _deleteMessageImages(mes, context);
    await _deleteMessageAudio(mes, context);
  }

  Future<void> _deleteMessageImages(
      ChatMessage mes, BuildContext context) async {
    if (mes.images != null) {
      if (mes.images!.isNotEmpty) {
        StorageBloc storageBlock = context.myData.sB;
        mes.images!.forEach((image) async {
          print("resim siliniyor = " + image!.ref!);
          await storageBlock.deleteMessageImage(currentUser.uid, image.ref!);
        });
      }
    }
  }

  Future<void> _deleteMessageAudio(
      ChatMessage mes, BuildContext context) async {
    if (mes.audio != null) {
      StorageBloc storageBlock = context.myData.sB;
      print("resim siliniyor = " + mes.audio!.ref!);
      await storageBlock.deleteMessageAudio(currentUser.uid, mes.audio!.ref!);
    }
  }

  Future<void> addMessage(
      String sender, String receiver, ChatMessage mesaj) async {
    String docId = getDoc(sender, receiver);
    await updateChat(docId, mesaj);
    await messagesColReference(docId)
        .doc(mesaj.senderId! + mesaj.messageTime.toString())
        .set(mesaj.toMap());
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessagesStream(
      String myUid) {
    return messagesReference.where("userIds", arrayContains: myUid).snapshots();
  }

  Future<void> setChatCard(String docId, Chat chat) async {
    await messagesReference.doc(docId).set(chat.toMap());
  }

  Future<void> updateChat(String docId, ChatMessage message) async {
    if ((message.message ?? "").isEmpty) {
      message = message.copyWith(
        message: getMesajFromType(message.messageType),
      );
    }
    await setChatCard(
      docId,
      Chat(message: message, userIds: docId.split("_")),
    );
  }

  String getMesajFromType(ChatMessageType? type) {
    switch (type) {
      case ChatMessageType.Image:
        return "resim 📷";
      default:
        return "ses";
    }
  }

  String getDoc(String? uid1, String? uid2) {
    List<String?> uids = [uid1, uid2];
    uids.sort();
    return uids.join("_");
  }

  void dispose() {
    lastMessagesStream!.close();
    lastMessagesSubscription!.cancel();
  }
}

MessagesService messagesService = MessagesService();
