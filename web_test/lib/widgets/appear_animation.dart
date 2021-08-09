import 'dart:async';

import 'package:flutter/material.dart';

class AppearAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback onTab;
  final bool isMultiTab;
  final double size;
  final bool isPlay;
  final int delay;
  final int reverseTime;
  final Curve curve;

  // String state;
  AppearAnimation(
      {this.child,
      this.onTab,
      this.isMultiTab,
      this.size: 0.1,
      this.isPlay: false,
      this.delay: 500,
      this.reverseTime,
      this.curve})
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
  Timer thirdTimer;
  double ratio = 1;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(
        duration: Duration(milliseconds: 500), vsync: this);

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
    if (thirdTimer != null) {
      thirdTimer.cancel();
    }
    super.dispose();
    // print('dispose');
    // screenModel.stopBackgroundMusic();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animationGrowSize = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.75, curve: Curves.easeInOut),
      ),
    );
    secondTimer = Timer(Duration(milliseconds: widget.delay), () {
      _animationController.forward();
    });
    if(widget.reverseTime!=null){
      thirdTimer=Timer(Duration(milliseconds: widget.reverseTime),(){
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationGrowSize,
      builder: (context, child) {
        return Transform.scale(
            scale: _animationGrowSize.value,
            child: isDisplayChild ? widget.child : Container());
      },
    );
  }
}
