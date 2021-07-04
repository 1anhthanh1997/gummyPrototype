import 'dart:async';

import 'package:flutter/material.dart';

class CorrectAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback onTab;
  final bool isCorrect;

  CorrectAnimation({this.child, this.onTab, this.isCorrect});

  _CorrectAnimationState createState() => _CorrectAnimationState();
}

class _CorrectAnimationState extends State<CorrectAnimation>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _scaleAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController =
        AnimationController(duration: Duration(milliseconds: 600), vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaleAnimation = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.75, curve: Curves.easeInBack),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCorrect) {
      Timer(Duration(milliseconds: 1000),(){
        _animationController.forward();
      });
    }
    return ScaleTransition(scale: _scaleAnimation, child: widget.child);
  }
}
