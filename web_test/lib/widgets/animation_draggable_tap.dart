import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_test/provider/screen_model.dart';

class AnimationDraggableTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTab;
  final bool isMultiTab;
  final double size;
  final bool isPlay;
  final int buttonId;

  // final VoidCallback onTapDown;

  // String state;
  AnimationDraggableTap(
      {this.child,
      this.onTab,
      this.isMultiTab,
      this.size: 0.1,
      this.isPlay: false,
      this.buttonId = 0})
      : super();

  @override
  _AnimationDraggableTaptate createState() => _AnimationDraggableTaptate();
}

class _AnimationDraggableTaptate extends State<AnimationDraggableTap>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _scaleAnimation;
  Cubic easeInBack = Cubic(0.6, -0.9, 0.735, 0.045);
  bool enable = true;
  Timer _timer;
  ScreenModel screenModel;

  @override
  void initState() {
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
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
          screenModel.logTapEvent(
              widget.buttonId, tapDownDetails.globalPosition);
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

        },
        onTap: (){
          if (widget.onTab != null) {
            widget.onTab();
          }
          if (widget.buttonId != null) {}
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
