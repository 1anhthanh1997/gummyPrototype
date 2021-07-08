import 'package:flutter/material.dart';

class OpacityAnimation extends StatefulWidget {
  final Widget child;
  final int isPlayAnimation;
  final int time;
  final double beginValue;
  final double endValue;
  final bool isScale;

  OpacityAnimation(
      {this.child,
        this.isPlayAnimation,
        this.time = 5000,
        this.beginValue = 0.2,
        this.endValue = 1.0,
        this.isScale=false});

  _OpacityAnimationState createState() => _OpacityAnimationState();
}

class _OpacityAnimationState extends State<OpacityAnimation>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(
        duration: Duration(milliseconds: widget.time), vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _opacityAnimation =
        Tween(begin: widget.beginValue, end: widget.endValue).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(0.0, 0.75, curve: Curves.linear),
          ),
        );
    _animationController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {

    return FadeTransition(opacity: _opacityAnimation, child: widget.child);
  }
}
