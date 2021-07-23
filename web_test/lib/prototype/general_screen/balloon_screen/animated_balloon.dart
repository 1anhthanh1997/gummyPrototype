import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:web_test/provider/screen_model.dart';

class AnimatedBalloon extends StatefulWidget {
  double height_screen;

  AnimatedBalloon({Key key, this.height_screen}) : super(key: key);

  _AnimatedBalloonState myAppState = new _AnimatedBalloonState();

  @override
  _AnimatedBalloonState createState() => myAppState;

  bool isDoneGame() {
    return myAppState.isDoneGame();
  }

  void playGame() {
    myAppState.startGame();
  }

  void endGame() {
    myAppState.endGame();
  }
}

class _AnimatedBalloonState extends State<AnimatedBalloon>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController _controller;
  Animation<double> _animationFloatUp;
  Animation<double> _animationGrowSize;

  double speed_balloon = 5;
  double _balloonHeight = 100;
  double _balloonWidth = 100;
  double _balloonLeft;
  double _balloonBottomLocation;
  double amplitude = 5;
  double timeDuaration = 4;
  bool isDone = false;
  bool isTap = false;
  int random = new Random().nextInt(100);
  Size sizeScreen;
  String imageBalloon = '';
  String imageBalloonCurrent = '';
  double screenWidth;
  double screenHeight;
  double ratio;
  Map<String, String> balloons = new Map();

  ScreenModel screenModel;

 Timer remindTimer;
  int tutorialCount = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    balloons['blue.svg'] = 'blue.gif';
    balloons['green.svg'] = 'green.gif';
    balloons['orange.svg'] = 'orange.gif';
    balloons['brown.svg'] = 'brown.gif';
    balloons['red.svg'] = 'red.gif';
    // //print('widget.height_screen ${widget.height_screen}');
    // double time =
    //     (widget.height_screen / speed_balloon) - (random / 100).toDouble();
    double time = timeDuaration - (random / 100).toDouble();
    imageBalloon =
        balloons.keys.toList()[new Random().nextInt(balloons.length)];
    imageBalloonCurrent = imageBalloon;
    _controller = AnimationController(
        duration: Duration(milliseconds: (time * 2000).toInt()), vsync: this);
    _controller.addListener(() {
      if (_controller.isCompleted) {
        endGame();
      }
    });
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizeScreen = MediaQuery.of(context).size;
    _balloonBottomLocation = sizeScreen.height - random;
    _balloonLeft = sizeScreen.width * new Random().nextDouble();
    if (_balloonLeft < (_balloonWidth + 2 * amplitude)) {
      _balloonLeft = (_balloonWidth + 2 * amplitude);
    } else if (_balloonLeft >
        (sizeScreen.width - _balloonWidth - 2 * amplitude)) {
      _balloonLeft = (sizeScreen.width - _balloonWidth - 2 * amplitude);
    }

    _animationFloatUp =
        Tween(begin: _balloonBottomLocation, end: -1 * _balloonHeight).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: Curves.linear),
      ),
    );

    _animationGrowSize = Tween(begin: 0.0, end: 100.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: Curves.linear),
      ),
    );
    if (_controller.isCompleted) {
      endGame();
    } else {
      startGame();
    }
  }

  genImage() {}

  startGame() {
    isDone = false;
    isTap = false;
    imageBalloonCurrent = imageBalloon;
    if (this.mounted) {
      setState(() {});
      _controller.forward();
    }
  }

  endGame() {
    isDone = true;
    // //print('isDime $isDone');
    if (this.mounted) {
      _controller.reset();
      setState(() {
      });
    }
    // _controller.reverse();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _controller.stop();
    }
    if (state == AppLifecycleState.resumed) {
      if (!isDone) {
        _controller.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight=screenModel.getScreenHeight();
    screenWidth=screenModel.getScreenWidth();
    ratio = screenModel.getRatio();
    return AnimatedBuilder(
      animation: _animationFloatUp,
      builder: (context, child) {
        double d = cos(pi * (1.5 + _animationGrowSize.value / 16));
        double bottom = _animationFloatUp.value < 0
            ? (_balloonBottomLocation - _animationFloatUp.value)
            : 0;
        double top = _animationFloatUp.value > 0 ? _animationFloatUp.value : 0;
        if (isTap && top > 40) {
          top -= 40;
        }
        return Container(
          child: isDone ? Container() : child,
          margin: EdgeInsets.only(
            top: top,
            bottom: bottom,
            left: _balloonLeft + (isTap ? -40 : 5 * d),
          ),
        );
      },
      child: GestureDetector(
        child: !isTap
            ? SvgPicture.asset(
                'assets/common/balloons/$imageBalloonCurrent',
                height: _animationFloatUp.value > 0
                    ? _balloonHeight * ratio
                    : (_balloonHeight + _animationFloatUp.value) * ratio,
                width: _balloonWidth * ratio,
                // fit: _animationFloatUp.value > 0 ? BoxFit.contain : BoxFit.fitWidth,
              )
            : Image.asset(
                'assets/common/balloons/$imageBalloonCurrent',
                height: (_balloonHeight + 50) * ratio,
                width: (_balloonWidth + 50) * ratio,
                // fit: _animationFloatUp.value > 0 ? BoxFit.contain : BoxFit.fitWidth,
              ),
        onTap: () {
          // //print("Broken");
          // screenModel.playBubbleBurstMusic();
          imageBalloonCurrent = balloons[imageBalloon];
          isTap = true;
          _controller.stop();
          setState(() {});
          Timer(Duration(milliseconds: 80), () {
            endGame();
          });
        },
      ),
    );
  }

  bool isDoneGame() {
    return isDone;
  }
}
