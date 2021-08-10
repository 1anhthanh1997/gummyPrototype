import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_test/config/id_config.dart';
import 'package:web_test/provider/screen_model.dart';

class TranslateCalculation extends StatefulWidget {
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

  TranslateCalculation(
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

  _TranslateCalculationState createState() => _TranslateCalculationState();
}

class _TranslateCalculationState extends State<TranslateCalculation>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _translateAnimation;
  ScreenModel screenModel;
  Timer firstTimer;
  Timer secondTimer;
  bool isPlay = true;

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
    if (widget.isScale) {
      firstTimer = Timer(Duration(milliseconds: 200), () {
        if (isPlay) {
          secondTimer = Timer(Duration(milliseconds: widget.delayTime), () {
          _animationController.forward().whenComplete(() {
              _animationController.reverse().whenComplete(() {
                setState(() {
                  isPlay = false;
                });
                Timer(Duration(milliseconds: 1500), () {
                  setState(() {
                    isPlay = true;
                  });
                });
              });
            });
          });
        }
      });
    }
    super.didChangeDependencies();
    _translateAnimation =
        Tween(begin: widget.beginValue, end: widget.endValue).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(0.0, 0.75, curve: widget.curve),
          ),
        );
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
  }

  @override
  Widget build(BuildContext context) {


    return AnimatedBuilder(
        animation: _animationController,
        builder: (BuildContext context, Widget child) {
          return Transform.translate(
              offset: Offset(0, _translateAnimation.value),
              child: widget.child);
        });
  }
}
