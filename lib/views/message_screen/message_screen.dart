import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  MessageScreen({Key? key}) : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mesaj Ekranı"),
      ),
      body: Center(
        child: Text("Mesaj"),
      ),
    );
  }
}
