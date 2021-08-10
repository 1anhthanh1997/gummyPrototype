import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_test/config/id_config.dart';
import 'package:web_test/provider/screen_model.dart';

class DraggableScale extends StatefulWidget {
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

  DraggableScale(
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

  _DraggableScaleState createState() => _DraggableScaleState();
}

class _DraggableScaleState extends State<DraggableScale>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _scaleAnimation;
  ScreenModel screenModel;
  Timer timer;
  Timer secondTimer;
  bool isPlay=true;

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
    _scaleAnimation =
        Tween(begin: widget.beginValue, end: widget.endValue).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(0.0, 0.75, curve: widget.curve),
          ),
        );

  }

  @override
  void dispose() {
    if(_animationController!=null){
      _animationController.dispose();
    }
    if(timer!=null){
      timer.cancel();
    }
    if(secondTimer!=null){
      secondTimer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isScale) {
      timer=Timer(Duration(milliseconds: widget.delayTime), () {
        // if(isPlay){
          _animationController.forward().whenComplete((){
            // setState(() {
            //   isPlay=false;
            // });
          });
        // }
      });
    }
    else {
      secondTimer=Timer(Duration(milliseconds: widget.delayTime), () {
        _animationController.reverse().whenComplete((){
          // setState(() {
          //   isPlay=true;
          // });
        });
      });
    }

    return GestureDetector(
        onTapDown: (details) {
          screenModel.logTapEvent(widget.itemId, details.globalPosition);
        },
        child: ScaleTransition(scale: _scaleAnimation, child: widget.child));
  }
}
