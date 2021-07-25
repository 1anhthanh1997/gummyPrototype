import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/particle.dart';

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
  List<String> balloonImage = [];
  List<Color> balloonColor = [];
  String chosenBalloonImage;
  Color chosenColor;

  ScreenModel screenModel;

  Timer remindTimer;
  int tutorialCount = 0;
  List<SquareParticle> particles = [];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    balloonImage.add('blue.png');
    balloonImage.add('cyan.png');
    balloonImage.add('green.png');
    balloonImage.add('purple.png');
    balloonImage.add('red.png');
    balloonImage.add('yellow.png');
    balloonColor.add(Colors.blue);
    balloonColor.add(Colors.cyan);
    balloonColor.add(Colors.green);
    balloonColor.add(Colors.purple);
    balloonColor.add(Colors.red);
    balloonColor.add(Colors.yellow);
    Random randomBalloon = Random();
    int index = randomBalloon.nextInt(balloonImage.length);
    chosenBalloonImage = balloonImage[index];
    chosenColor = balloonColor[index];
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
    // screenModel = Provider.of<ScreenModel>(context, listen: false);
    // screenModel.setContext(context);
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
    if (_balloonLeft > sizeScreen.width - 71) {
      _balloonLeft = sizeScreen.width - 71;
    }

    _animationFloatUp = Tween(begin: sizeScreen.height, end: -200.0).animate(
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
      setState(() {});
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

  void hitBalloon(Duration time) {
    imageBalloonCurrent = balloons[imageBalloon];
    isTap = true;
    _controller.stop();
    setState(() {});
    // Timer(Duration(milliseconds: 80), () {
    //   endGame();
    // });
    Iterable.generate(8).forEach((i) => particles.add(SquareParticle(time, 1)));
  }

  Widget _buildParticle() {
    return Rendering(
      // onTick: (time) => _manageParticleLife(time),
      builder: (context, time) {
        return Stack(
          overflow: Overflow.visible,
          children: [
            GestureDetector(
                onTap: () {
                  print('Hit');
                  hitBalloon(time);
                },
                child: displayBubble()),
            ...particles.map((it) => it.buildWidget(time, chosenColor))
          ],
        );
      },
    );
  }

  Widget displayBubble() {
    return isTap?Container(): Container(
      height: 150,
      width: 71,
      child: Image.asset(
        'assets/images/common/balloons/${chosenBalloonImage}',
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // screenHeight=screenModel.getScreenHeight();
    // screenWidth=screenModel.getScreenWidth();
    // ratio = screenModel.getRatio();

    return AnimatedBuilder(
      animation: _animationFloatUp,
      builder: (context, child) {

        return
            Transform.translate(
              offset: Offset(_balloonLeft,_animationFloatUp.value),
              child: isDone ? Container() : child,
            );

      },
      child: _buildParticle(),
    );
  }

  bool isDoneGame() {
    return isDone;
  }
}
