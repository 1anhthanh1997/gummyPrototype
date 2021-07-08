import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:gummy/providers/screen_model.dart';
// import 'package:provider/provider.dart';
// import 'package:rive/rive.dart';

class AnimatedMatchedTarget extends StatefulWidget {
  final Widget child;


  // String state;
  AnimatedMatchedTarget({Key key, this.child})
      : super(key: key);

  @override
  _AnimatedMatchedTargetState createState() => _AnimatedMatchedTargetState();
}

class _AnimatedMatchedTargetState extends State<AnimatedMatchedTarget>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _scaleAnimation;
  Cubic easeOutBack = Cubic(0.175, 0.885, 0.32, 1.6);
  // ScreenModel screenModel;
  bool enable = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController =
        AnimationController(duration: Duration(milliseconds: 1000), vsync: this);
    // screenModel = Provider.of<ScreenModel>(context, listen: false);
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
    _scaleAnimation = Tween(begin: 1.1, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.75, curve: easeOutBack),
      ),
    );
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale:_scaleAnimation.value,
              child: child,
            );
          },
          child: widget.child,
        ),
    );
  }
}
