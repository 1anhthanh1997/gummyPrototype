import 'package:flutter/material.dart';

class ScaleAnimation extends StatefulWidget {
   final Widget child;
   final VoidCallback onTab;

  ScaleAnimation({ this.child,  this.onTab});

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
    _animationController =
        AnimationController(duration: Duration(milliseconds: 400), vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaleAnimation = Tween(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.75, curve: Curves.linear),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
