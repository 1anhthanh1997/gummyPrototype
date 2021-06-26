import 'dart:math';

import 'package:flutter/material.dart';


class AnimationHitFail extends StatefulWidget {
  final Widget child;
  final bool isDisplayAnimation;

  // String state;
  AnimationHitFail({ required this.child, this.isDisplayAnimation=false})
      : super();

  @override
  _AnimationHitFailState createState() => _AnimationHitFailState();
}

class _AnimationHitFailState extends State<AnimationHitFail>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _animationTransition;
  late Animation<double> _translateAnimation;
  late Animation<double> _rotateAnimation;
  Cubic easeOutBack = Cubic(0.175, 0.885, 0.32, 1.6);
  bool enable = true;
  int times = 0;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _animationController
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (times < 1) {
            _animationController.reverse();
            times++;
          } else {
            _animationController.reset();
            _animationController.stop();
          }
        } else if (status == AnimationStatus.dismissed) {
          _animationController.forward();
        }
      });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if(_animationController!=null){
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rotateAnimation = Tween(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.75, curve: Curves.linear),
      ),
    );
    if (widget.isDisplayAnimation) {
      _animationController.forward();
      // Timer(Duration(milliseconds: 200), () {
      //   _animationController.reverse();
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AnimatedBuilder(
        animation: _rotateAnimation,
        builder: (context, child) {
          double angle = _animationController.isAnimating
              ? _rotateAnimation.value * pi / 15
              : 0;
          return Transform.rotate(
            angle: angle,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
