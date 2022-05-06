import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AudiosBlog {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<dynamic> audiosList = [];
  void getAudiosMusic() async {
    await _firestore.collection("audios").get().then((value) {
      audiosList =
          value.docs.map((value) => dynamic.fromMap(value.data())).toList();
    });
  }
}
