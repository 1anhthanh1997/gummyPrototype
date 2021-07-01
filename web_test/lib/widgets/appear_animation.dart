import 'dart:async';

import 'package:flutter/material.dart';

class AppearAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback onTab;
  final bool isMultiTab;
  final double size;
  final bool isPlay;
  final int delay;

  // String state;
  AppearAnimation(
      {this.child,
      this.onTab,
      this.isMultiTab,
      this.size: 0.1,
      this.isPlay: false,
      this.delay: 500})
      : super();

  @override
  _AppearAnimationState createState() => _AppearAnimationState();
}

class _AppearAnimationState extends State<AppearAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animationGrowSize;
  Cubic easeInOutBack = Cubic(0.68, -0.2, 0.265, 1.2);
  bool isDisplayChild = false;
  Timer firstTimer;
  Timer secondTimer;
  double ratio = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(
        duration: Duration(milliseconds: 1500), vsync: this);

    firstTimer = Timer(Duration(milliseconds: widget.delay), () {
      setState(() {
        isDisplayChild = true;
      });
    });
  }

  @override
  void dispose() {
    if (_animationController != null) {
      _animationController.dispose();
    }
    if (firstTimer != null) {
      firstTimer.cancel();
    }
    if (secondTimer != null) {
      secondTimer.cancel();
    }
    super.dispose();
    // print('dispose');
    // screenModel.stopBackgroundMusic();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animationGrowSize = Tween(begin: -0.5, end: 0.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.75, curve: Curves.easeInOutQuart),
      ),
    );
    secondTimer = Timer(Duration(milliseconds: widget.delay), () {
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationGrowSize,
      builder: (context, child) {
        return Transform.scale(
            scale: _animationGrowSize.value < 0.1 &&
                    _animationGrowSize.value > -0.1
                ? 0.1 * 0.1 * 4
                : _animationGrowSize.value * _animationGrowSize.value * 4,
            child: isDisplayChild ? widget.child : Container());
      },
    );
  }
}
