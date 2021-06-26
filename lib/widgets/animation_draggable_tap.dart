import 'dart:async';

import 'package:flutter/material.dart';


class AnimationDraggableTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTab;
  final bool isMultiTab;
  final double size;
  final bool isPlay;
  final String buttonName;

  // final VoidCallback onTapDown;

  // String state;
  AnimationDraggableTap({
    required this.child,
    required this.onTab,
    required this.isMultiTab,
    this.size: 0.1,
    this.isPlay: false,
    this.buttonName=''
  })
      : super();

  @override
  _AnimationDraggableTaptate createState() => _AnimationDraggableTaptate();
}

class _AnimationDraggableTaptate extends State<AnimationDraggableTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  Cubic easeInBack = Cubic(0.6, -0.9, 0.735, 0.045);
  bool enable = true;
  late Timer _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController =
        AnimationController(duration: Duration(milliseconds: 400), vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (_animationController != null) {
      _animationController.dispose();
    }
    if (_timer != null) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaleAnimation = Tween(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.75, curve: Curves.linear),
      ),
    );
    if (widget.isPlay) {
      if (_animationController.isCompleted) {
        _animationController.reset();
        _animationController.forward();
      } else {
        _animationController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isPlay) {
      if (_animationController.isCompleted) {
        _animationController.reset();
        _animationController.forward();
      } else {
        _animationController.forward();
      }
    }
    return AbsorbPointer(
      absorbing: widget.isMultiTab == null || widget.isMultiTab == true
          ? false
          : !enable,
      child: GestureDetector(
        onDoubleTap: () {
          return;
        },
        onTapDown: (TapDownDetails tapDownDetails) {
          setState(() {
            enable = false;
          });
          _timer = Timer(Duration(milliseconds: 1000), () {
            setState(() {
              enable = true;
            });
          });
          _animationController.reset();
          _animationController.forward();
          if (widget.onTab != null) {
            widget.onTab();
          }
          if(widget.buttonName!=null) {}
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: (-1 *
                  widget.size *
                  _scaleAnimation.value *
                  _scaleAnimation.value) +
                  1 +
                  widget.size,
              child: child,
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
