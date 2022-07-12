import 'dart:math';

import 'package:flutter/material.dart';
import 'package:onlinemusic/widgets/decorated_icon.dart';

class FavoriteAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback onDoubleTap;
  final bool finishAnimationCallback;
  const FavoriteAnimation({
    Key? key,
    required this.child,
    required this.onDoubleTap,
    this.finishAnimationCallback = false,
  }) : super(key: key);

  @override
  State<FavoriteAnimation> createState() => _FavoriteAnimationState();
}

class _FavoriteAnimationState extends State<FavoriteAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: Duration(milliseconds: 600), vsync: this);

    _scaleAnim =
        CurvedAnimation(parent: _controller, curve: Curves.elasticInOut);
  }

  void playAnim() {
    if (!_controller.isAnimating) {
      _controller.forward().then((value) {
        Future.delayed(Duration(milliseconds: 600), () {
          _controller.reverse().then((value) {
            if (widget.finishAnimationCallback) {
              widget.onDoubleTap();
            }
          });
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onDoubleTap: () {
            playAnim();
            if (!widget.finishAnimationCallback) {
              widget.onDoubleTap();
            }
          },
          child: widget.child,
        ),
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, con) {
              double size = min(con.maxHeight, con.maxWidth);
              return AnimatedBuilder(
                animation: _scaleAnim,
                builder: (BuildContext context, _) {
                  return Transform.scale(
                    scale: _scaleAnim.value,
                    child: Center(
                      child: DecoratedIcon(
                        Icons.favorite,
                        color: Colors.white,
                        size: size * 0.8,
                        shadows: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 16,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
