import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class SlideAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback onTab;
  final int isPlayAnimation;
  final double beginValue;
  final double endValue;
  final int time;

  SlideAnimation(
      {this.child,
      this.onTab,
      this.isPlayAnimation,
      this.beginValue = -5.0,
      this.endValue = 5.0,
      this.time});

  _SlideAnimationState createState() => _SlideAnimationState();
}

class _SlideAnimationState extends State<SlideAnimation>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _slideAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Random rdm = Random();
    int time = widget.time == null ? (rdm.nextInt(20) + 40) * 20 : widget.time;
    _animationController =
        AnimationController(duration: Duration(milliseconds: time), vsync: this)
          ..repeat(reverse: false );
  }

  @override
  void dispose() {
    if (_animationController != null) {
      _animationController.dispose();
    }
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _slideAnimation =
        Tween(begin: widget.beginValue, end: widget.endValue).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.75, curve: Curves.linear),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (BuildContext context, Widget child) {
          return Transform.translate(
              offset: Offset(_slideAnimation.value, 0), child: widget.child);
        });
  }
}
