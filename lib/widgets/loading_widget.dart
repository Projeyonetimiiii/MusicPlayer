import 'package:flutter/material.dart';
import 'package:skeleton_animation/skeleton_animation.dart';

class LoadingCard extends StatelessWidget {
  final double height;
  const LoadingCard({Key? key, required this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: Skeleton(
          style: SkeletonStyle.text, textColor: Colors.white10, height: height),
    );
  }
}
