import 'package:flutter/material.dart';

class MyDismissible extends StatelessWidget {
  final void Function(DismissDirection)? onDismissed;
  final Widget child;
  final Key key;
  const MyDismissible({
    required this.key,
    required this.child,
    this.onDismissed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      background: Container(
        color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Icon(Icons.delete, color: Colors.white),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Icon(Icons.delete, color: Colors.white),
            ),
          ],
        ),
      ),
      onDismissed: onDismissed,
      key: key,
      child: child,
    );
  }
}
