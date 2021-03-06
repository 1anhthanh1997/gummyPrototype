import 'dart:math';

import 'package:flutter/material.dart';

class BubbleAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback onTab;
  final int isPlayAnimation;
  final double beginValue;
  final double endValue;
  final int time;


  BubbleAnimation(
      {this.child, this.onTab, this.isPlayAnimation, this.beginValue=-5.0, this.endValue=5.0, this.time});

  _BubbleAnimationState createState() => _BubbleAnimationState();
}

class _BubbleAnimationState extends State<BubbleAnimation>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _bubbleAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Random rdm = Random();
    int time=widget.time==null?(rdm.nextInt(20)+40)*20:widget.time;
    _animationController =
        AnimationController(duration: Duration(milliseconds: time), vsync: this)
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    if(_animationController!=null){
    _animationController.dispose();
    }
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bubbleAnimation = Tween(begin: widget.beginValue, end: widget.endValue).animate(
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
              offset: Offset(0, _bubbleAnimation.value), child: widget.child);
        });
  }
}
