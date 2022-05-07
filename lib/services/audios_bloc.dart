import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlinemusic/models/audio.dart';

class AudiosBloc {
  late final FirebaseFirestore _firestore;
  List<Audio> audioList = [];

  CollectionReference<Map<String, dynamic>> get audiosReference =>
      _firestore.collection("audios");

  AudiosBloc() {
    _firestore = FirebaseFirestore.instance;
  }

  void getAudiosMusic() async {
    await audiosReference.get().then((value) {
      audioList =
          value.docs.map((value) => Audio.fromMap(value.data())).toList();
    });
  }
}
