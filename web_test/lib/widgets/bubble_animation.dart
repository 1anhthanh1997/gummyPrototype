import 'package:flutter/material.dart';

class BubbleAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback onTab;
  final int isPlayAnimation;
  final Offset position;

  BubbleAnimation(
      {this.child, this.onTab, this.isPlayAnimation, this.position});

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
    _animationController =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this)
          ..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bubbleAnimation = Tween(begin: -30.0, end: 30.0).animate(
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
              offset: Offset(widget.position.dx,
                  widget.position.dy + _bubbleAnimation.value));
        });
  }
}
