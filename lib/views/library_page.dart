import 'package:flutter/material.dart';

class LibraryPage extends StatefulWidget {
  LibraryPage({Key? key}) : super(key: key);

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cihaz"),
      ),
      body: Center(
        child: Text("Cihaz ekranı"),
      ),
    );
  }
}
