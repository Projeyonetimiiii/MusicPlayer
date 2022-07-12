import 'package:flutter/material.dart';
import 'package:onlinemusic/util/const.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double horizontalPadding;
  final EdgeInsets contentPadding;
  final bool readOnly;
  final bool obscureText;
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  CustomTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.readOnly = false,
    this.obscureText = false,
    this.horizontalPadding = 12,
    this.contentPadding = const EdgeInsets.symmetric(
      vertical: 12,
    ),
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Const.contrainsColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
        child: TextField(
          obscureText: widget.obscureText,
          onSubmitted: widget.onSubmitted,
          onChanged: widget.onChanged,
          maxLines: widget.maxLines,
          readOnly: widget.readOnly,
          controller: widget.controller,
          cursorColor: Const.contrainsColor,
          cursorRadius: Radius.circular(4),
          cursorWidth: 1,
          decoration: InputDecoration(
            contentPadding: widget.contentPadding,
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
