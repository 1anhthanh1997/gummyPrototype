import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimationColor extends StatefulWidget {
  Color beginColor;
  Color endColor;
  bool isChangeColor;
  String pathString;
  String url;

  AnimationColor(
      {
         this.beginColor,
         this.endColor,
         this.isChangeColor,
         this.pathString,
         this.url})
      : super();

  _AnimationColorState colorState = new _AnimationColorState();

  @override
  _AnimationColorState createState() => _AnimationColorState();

  changeColor() {
    colorState.animateColor();
  }
}

class _AnimationColorState extends State<AnimationColor>
    with SingleTickerProviderStateMixin {
  Animation<Color> animation;
  AnimationController controller;
  bool isFirstTime = true;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    animation = ColorTween(begin: widget.beginColor, end: widget.endColor)
        .animate(controller)
      ..addListener(() {
        setState(() {
          // The state that has changed here is the animation object’s value.
        });
      });
  }

  void animateColor() {
    if (controller.isCompleted) {
      controller.reverse();
    } else {
      controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isChangeColor && isFirstTime) {
      // print('Yes');
      animateColor();
      setState(() {
        isFirstTime = false;
      });
    }
    return Container(
      child: SvgPicture.asset(
        widget.url,
        fit: BoxFit.contain,
        // color: animation.value,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
