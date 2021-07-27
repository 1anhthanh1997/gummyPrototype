import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_test/config/id_config.dart';
import 'package:web_test/provider/screen_model.dart';

class CorrectAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback onTab;
  final bool isCorrect;
  final int delayTime;

  CorrectAnimation({this.child, this.onTab, this.isCorrect,this.delayTime=100});

  _CorrectAnimationState createState() => _CorrectAnimationState();
}

class _CorrectAnimationState extends State<CorrectAnimation>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _scaleAnimation;
  ScreenModel screenModel;
  bool isFirstTime=true;

  @override
  void initState() {
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
    // TODO: implement initState
    super.initState();
    _animationController =
        AnimationController(duration: Duration(milliseconds: 600), vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaleAnimation = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.75, curve: Curves.easeInBack),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCorrect) {
      Timer(Duration(milliseconds: widget.delayTime),(){
        print('Play sound');
        if(isFirstTime){
          screenModel.playGameItemSound(SCALE_DOWN);
          setState(() {
            isFirstTime=false;
          });
        }
        _animationController.forward();
      });
    }
    return ScaleTransition(scale: _scaleAnimation, child: widget.child);
  }
}
