import 'package:flutter/material.dart';

class ShareSongScreen extends StatefulWidget {
  ShareSongScreen({Key? key}) : super(key: key);

  @override
  State<ShareSongScreen> createState() => _ShareSongScreenState();
}

class _ShareSongScreenState extends State<ShareSongScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Müzik Paylaş"),
      ),
    );
  }
}
