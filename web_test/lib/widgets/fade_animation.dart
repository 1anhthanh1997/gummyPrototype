import 'package:flutter/material.dart';

class FadeAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback onTab;
  final bool isPlayAnimation;
  final int time;
  final double beginValue;
  final double endValue;
  final bool isFade;
  final Curve curve;

  FadeAnimation(
      {this.child,
      this.onTab,
      this.isPlayAnimation,
      this.time = 300,
      this.beginValue = 0.0,
      this.endValue = 1.0,
      this.isFade = false,
      this.curve = Curves.linear});

  _FadeAnimationState createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _fadeAnimation;

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
    _fadeAnimation =
        Tween(begin: widget.beginValue, end: widget.endValue).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.75, curve: widget.curve),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFade) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    return FadeTransition(opacity: _fadeAnimation, child: widget.child);
  }
}
