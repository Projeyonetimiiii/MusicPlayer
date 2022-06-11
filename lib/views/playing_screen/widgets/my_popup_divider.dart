import 'package:flutter/material.dart';

class MyPopupMenuDivider<T> extends PopupMenuEntry<T> {
  /// Creates a horizontal divider for a popup menu.
  ///
  /// By default, the divider has a height of 16 logical pixels.
  const MyPopupMenuDivider({
    Key? key,
    this.height = 16,
    this.tickness = 1,
    this.color,
  }) : super(key: key);

  /// The height of the divider entry.
  ///
  /// Defaults to 16 pixels.
  @override
  final double height;

  final Color? color;

  final double tickness;

  @override
  bool represents(void value) => false;

  @override
  State<MyPopupMenuDivider> createState() => _PopupMenuDividerState();
}

class _PopupMenuDividerState extends State<MyPopupMenuDivider> {
  @override
  Widget build(BuildContext context) => Divider(
        height: widget.height,
        thickness: widget.tickness,
        color: widget.color,
      );
}
