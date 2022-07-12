import 'dart:async';

import 'package:flutter/material.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:overlay_support/overlay_support.dart';

typedef ActionsBuilder = List<Widget>? Function(OverlaySupportEntry?);

class MyOverlayNotification extends StatelessWidget {
  final Duration duration;
  final String message;
  final List<Widget>? actions;
  final VoidCallback? onFinish;
  final Widget? leading;

  MyOverlayNotification({
    this.actions,
    required this.duration,
    required this.message,
    this.onFinish,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(duration),
      direction: DismissDirection.horizontal,
      confirmDismiss: (s) {
        onFinish?.call();
        return Future.value(true);
      },
      child: Material(
        color: Const.contrainsColor,
        elevation: 4,
        child: SafeArea(
          child: IntrinsicHeight(
            child: Container(
              constraints: BoxConstraints(
                minHeight: AppBar().preferredSize.height,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (leading != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: leading!,
                          ),
                        ],
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              message,
                              style: TextStyle(
                                fontSize: 13,
                                color: Const.themeColor,
                              ),
                            ),
                          ),
                        ),
                        if (actions != null)
                          Row(
                            children: actions!,
                          ),
                      ],
                    ),
                  ),
                  LinearCountDownWidget(
                    duration: duration,
                    onFinish: onFinish,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LinearCountDownWidget extends StatefulWidget {
  LinearCountDownWidget({
    Key? key,
    required this.duration,
    this.onFinish,
  }) : super(key: key);
  final Duration duration;
  final VoidCallback? onFinish;

  @override
  State<LinearCountDownWidget> createState() => _LinearCountDownWidgetState();
}

class _LinearCountDownWidgetState extends State<LinearCountDownWidget> {
  StreamSubscription? subscription;
  Duration duration = Duration.zero;
  double val = 1;

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  startTimer() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      subscription =
          Stream.periodic(Duration(milliseconds: 16)).listen((event) {
        setState(() {
          duration = Duration(milliseconds: duration.inMilliseconds + 16);
          val = 1 - (duration.inMilliseconds / widget.duration.inMilliseconds);
          if (val < 0) {
            subscription?.cancel();
            widget.onFinish?.call();
          }
        });
      });
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: val.clamp(0, 1),
      valueColor: AlwaysStoppedAnimation(
        Const.themeColor,
      ),
      backgroundColor: Colors.transparent,
    );
  }
}

showMessage({
  required String message,
}) {
  showMyOverlayNotification(duration: Duration(seconds: 3), message: message);
}

showMyOverlayNotification({
  ActionsBuilder? actionsBuilder,
  Widget? leading,
  required Duration duration,
  required String message,
  VoidCallback? onFinish,
}) {
  OverlaySupportEntry? entry;
  entry = showOverlayNotification(
    (context) {
      return MyOverlayNotification(
        duration: duration,
        leading: leading,
        actions: actionsBuilder?.call(OverlaySupportEntry.of(context)),
        message: message,
        onFinish: () {
          entry?.dismiss();
          onFinish?.call();
        },
      );
    },
    duration: Duration.zero,
    position: NotificationPosition.top,
  );
}
