import 'package:flutter/material.dart';
import 'package:onlinemusic/util/const.dart';

class ProgressPainter extends CustomPainter {
  double progress;

  ProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double h = size.height;

    Paint paint = Paint()
      ..color = Const.contrainsColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    double topRight = 0;
    double bottomRight = 0;
    double bottomLeft = 0;

    Path path = Path();

    double topProgress = progress + 0.1;

    topRight = w * topProgress;
    topRight = topRight.clamp(0, w);

    bottomRight = w * progress;

    path.lineTo(topRight, 0);

    if (topProgress >= 1) {
      path.lineTo(w, h * ((progress - 0.9) / .1));
    }

    path.lineTo(bottomRight, h);
    path.lineTo(bottomLeft, h);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// class ProgressClipper extends CustomClipper<Path> {
//   double progress;

//   ProgressClipper(this.progress);

//   @override
//   Path getClip(Size size) {
//     double w = size.width;
//     double h = size.height;

//     Paint paint = Paint()
//       ..color = Const.contrainsColor.withOpacity(0.4)
//       ..style = PaintingStyle.fill;

//     double topRight = 0;
//     double bottomRight = 0;
//     double bottomLeft = 0;

//     Path path = Path();

//     topRight = w * (progress + 0.1);
//     topRight = topRight.clamp(0, w);

//     bottomRight = w * progress;

//     path.lineTo(topRight, 0);
//     path.lineTo(bottomRight, h);
//     path.lineTo(bottomLeft, h);
//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
// }
