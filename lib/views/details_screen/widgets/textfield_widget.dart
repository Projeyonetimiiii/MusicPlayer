import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final TextEditingController? controller;
  const TextFieldWidget({Key? key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(
          color: Colors.white,
          decoration: TextDecoration.none,
          decorationThickness: 0,
          decorationColor: Colors.transparent),
      cursorColor: Colors.white,
      controller: controller,
      cursorRadius: Radius.circular(8),
      cursorWidth: 1.5,
      decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Mesajınız...",
          hintStyle: TextStyle(color: Colors.white60)),
    );
  }
}
