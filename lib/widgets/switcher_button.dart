library switcher_button;

import 'package:flutter/material.dart';

class SwitcherButton extends StatefulWidget {
  late final double _width, _height;

  final double size;

  final Color onColor, offColor;

  final bool value;

  final Function(bool value)? onChange;

  SwitcherButton({
    Key? key,
    this.size = 60.0,
    this.onColor = Colors.white,
    this.offColor = Colors.black87,
    this.value = false,
    this.onChange,
  }) : super(key: key) {
    _width = size;
    _height = size / 2;
  }

  @override
  SwitcherButtonState createState() => SwitcherButtonState();
}

class SwitcherButtonState extends State<SwitcherButton>
    with TickerProviderStateMixin {
  @override
  void dispose() {
    _rightController.dispose();
    _leftController.dispose();
    super.dispose();
  }

  late bool value;

  double _rightRadius = 0.0;

  double _leftRadius = 0.0;

  late Animation<double> _rightRadiusAnimation, _leftRadiusAnimation;

  late AnimationController _rightController, _leftController;

  @override
  void initState() {
    value = widget.value;

    _rightController = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _leftController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    if (value) {
      _leftRadius = widget._width * 2;
      _rightRadiusAnimation = Tween(begin: 0.0, end: widget._height * .18)
          .animate(CurvedAnimation(
              parent: _rightController, curve: Curves.elasticOut))
        ..addListener(() {
          setState(() {
            _rightRadius = _rightRadiusAnimation.value;
          });
        });
      _rightController.forward();
    } else {
      _rightRadius = widget._width * 2;
      _leftRadiusAnimation = Tween(begin: 0.0, end: widget._height * .18)
          .animate(CurvedAnimation(
              parent: _leftController, curve: Curves.elasticOut))
        ..addListener(() {
          setState(() {
            _leftRadius = _leftRadiusAnimation.value;
          });
        });
      _leftController.forward();
    }

    super.initState();
  }

  @override
  void didUpdateWidget(SwitcherButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (!isAnimating) _changeState();
    }
  }

  bool get isAnimating =>
      _rightController.isAnimating || _leftController.isAnimating;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isAnimating) _changeState();
      },
      child: Container(
        width: widget._width,
        height: widget._height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10000.0))),
        child: CustomPaint(
          size: Size.infinite,
          painter: ProfileCardPainter(
            offColor: widget.offColor,
            onColor: widget.onColor,
            leftRadius: _leftRadius,
            rightRadius: _rightRadius,
            value: value,
          ),
        ),
      ),
    );
  }

  _changeState() {
    _rightController = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);
    _leftController = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);

    if (value) {
      _rightController.duration = Duration(milliseconds: 200);

      _rightRadiusAnimation = Tween(
              begin: widget._height * .18, end: widget._width)
          .animate(_rightController)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            setState(() {
              _leftRadius = 0.0;
              value = false;
            });
            _leftController.reset();
            _leftController.duration = Duration(milliseconds: 400);
            _leftRadiusAnimation = Tween(begin: 0.0, end: widget._height * .18)
                .animate(CurvedAnimation(
                    parent: _leftController, curve: Curves.elasticOut))
              ..addListener(() {
                setState(() {
                  _leftRadius = _leftRadiusAnimation.value;
                });
              });
            _leftController.forward();
          }
        })
        ..addListener(() {
          setState(() {
            _rightRadius = _rightRadiusAnimation.value;
          });
        });
      _rightController.forward();
    } else {
      _leftController.duration = Duration(milliseconds: 200);

      _leftRadiusAnimation = Tween(
              begin: widget._height * .18, end: widget._width)
          .animate(_leftController)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            setState(() {
              _rightRadius = 0.0;
              value = true;
            });
            _rightController.reset();
            _rightController.duration = Duration(milliseconds: 400);
            _rightRadiusAnimation = Tween(begin: 0.0, end: widget._height * .18)
                .animate(CurvedAnimation(
                    parent: _rightController, curve: Curves.elasticOut))
              ..addListener(() {
                setState(() {
                  _rightRadius = _rightRadiusAnimation.value;
                });
              });
            _rightController.forward();
          }
        })
        ..addListener(() {
          setState(() {
            _leftRadius = _leftRadiusAnimation.value;
          });
        });
      _leftController.forward();
    }

    if (widget.onChange != null) widget.onChange!(!value);
  }
}

class ProfileCardPainter extends CustomPainter {
  late double rightRadius;

  late double leftRadius;

  late bool value;

  late Color onColor;

  late Color offColor;

  ProfileCardPainter({
    required this.rightRadius,
    required this.leftRadius,
    required this.value,
    required this.onColor,
    required this.offColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (value) {
      var paint = Paint()
        ..color = onColor
        ..strokeWidth = 18;
      Offset center = Offset((size.width / 2) / 2, size.height / 2);
      canvas.drawCircle(center, leftRadius, paint);

      paint.color = offColor;
      center =
          Offset(((size.width / 2) / 2) + (size.width / 2), size.height / 2);
      canvas.drawCircle(center, rightRadius, paint);
    } else {
      var paint = Paint()..strokeWidth = 18;
      Offset center;

      paint.color = offColor;
      center =
          Offset(((size.width / 2) / 2) + (size.width / 2), size.height / 2);
      canvas.drawCircle(center, rightRadius, paint);

      paint.color = onColor;
      center = Offset((size.width / 2) / 2, size.height / 2);
      canvas.drawCircle(center, leftRadius, paint);
    }
  }

  @override
  bool shouldRepaint(ProfileCardPainter oldDelegate) {
    return true;
  }
}
