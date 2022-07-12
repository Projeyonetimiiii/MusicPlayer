import 'package:flutter/material.dart';

class AppLifecycle extends StatefulWidget {
  final Widget child;
  final ValueChanged<AppLifecycleState>? changeLifecycle;
  AppLifecycle({
    Key? key,
    required this.child,
    this.changeLifecycle,
  }) : super(key: key);

  @override
  State<AppLifecycle> createState() => _AppLifecycleState();
}

class _AppLifecycleState extends State<AppLifecycle>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.changeLifecycle != null) {
      widget.changeLifecycle!(state);
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
