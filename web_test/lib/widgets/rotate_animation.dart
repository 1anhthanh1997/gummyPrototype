import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_test/config/id_config.dart';
import 'package:web_test/provider/screen_model.dart';

class RotateAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback onTab;
  final int isPlayAnimation;
  final int time;
  final double beginValue;
  final double endValue;
  final bool isScale;
  final Curve curve;
  final int itemId;
  final int delayTime;
  final bool isReverse;

  RotateAnimation(
      {this.child,
      this.onTab,
      this.isPlayAnimation,
      this.time = 300,
      this.beginValue = 1.0,
      this.endValue = 1.2,
      this.isScale = false,
      this.curve = Curves.linear,
      this.itemId = 0,
      this.delayTime = 0,
      this.isReverse = false});

  _RotateAnimationState createState() => _RotateAnimationState();
}

class _RotateAnimationState extends State<RotateAnimation>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _rotateAnimation;
  ScreenModel screenModel;

  @override
  void initState() {
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
    super.initState();
    _animationController = AnimationController(
        duration: Duration(milliseconds: widget.time), vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rotateAnimation =
        Tween(begin: widget.beginValue, end: widget.endValue).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.75, curve: widget.curve),
      ),
    );
    // _animationController.forward();
  }

  @override
  void dispose() {
    if (_animationController != null) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (widget.isScale) {
    //
    // }

    return AnimatedBuilder(
        animation: _rotateAnimation,
        builder: (context, child) {
          double angle = _rotateAnimation.value;

          return Transform.rotate(
            angle: angle,
            child: child,
          );
        },
        child: GestureDetector(
            onTapDown: (details) {
              screenModel.logTapEvent(widget.itemId, details.globalPosition);
            },
            onTap: () {
              print('Hello');
              _animationController.forward().whenComplete(() {
                _animationController.reverse();
              });
              if (widget.onTab != null) {
                widget.onTab();
              }
            },
            child: Transform.rotate(
                angle: _rotateAnimation.value, child: widget.child)));
  }
}
