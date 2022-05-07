import 'package:cloud_firestore/cloud_firestore.dart';

class AudiosBloc {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<dynamic> audiosList = [];
  void getAudiosMusic() async {
    await _firestore.collection("audios").get().then((value) {
      audiosList =
          value.docs.map((value) => dynamic.fromMap(value.data())).toList();
    });
  }
}
