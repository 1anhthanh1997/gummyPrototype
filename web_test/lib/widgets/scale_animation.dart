import 'package:flutter/material.dart';

class ScaleAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback onTab;
  final int isPlayAnimation;
  final int time;
  final double beginValue;
  final double endValue;
  final bool isScale;
  final Curve curve;

  ScaleAnimation(
      {this.child,
      this.onTab,
      this.isPlayAnimation,
      this.time = 300,
      this.beginValue = 1.0,
      this.endValue = 1.2,
      this.isScale = false,
      this.curve = Curves.linear});

  _ScaleAnimationState createState() => _ScaleAnimationState();
}

class _ScaleAnimationState extends State<ScaleAnimation>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _scaleAnimation;

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
    _scaleAnimation =
        Tween(begin: widget.beginValue, end: widget.endValue).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.75, curve: widget.curve),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isScale) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    return GestureDetector(
        onTap: () {
          widget.onTab();
          if (_scaleAnimation.isCompleted) {
            _animationController.reverse();
          } else {
            _animationController.forward();
          }
        },
        child: ScaleTransition(scale: _scaleAnimation, child: widget.child));
  }
}
