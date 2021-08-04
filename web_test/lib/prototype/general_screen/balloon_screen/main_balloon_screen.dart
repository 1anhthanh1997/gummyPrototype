import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:web_test/prototype/general_screen/balloon_screen/animated_balloon.dart';
import 'package:web_test/provider/screen_model.dart';

class MainBalloonScreen extends StatefulWidget {

  @override
  _MainBalloonState createState() => _MainBalloonState();
}

class _MainBalloonState extends State<MainBalloonScreen>
    with WidgetsBindingObserver {
  List<Widget> items = new List();
  bool isForceGround = true;
  double height_screen;
  ScreenModel screenModel;

 Timer remindTimer;
  int tutorialCount = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    // screenModel = Provider.of<ScreenModel>(context, listen: false);
    // screenModel.setContext(context);
    genItems();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    for (var i = 0; i < items.length; i++) {
      AnimatedBalloon item = items[i];
      item.endGame();
    }
  }

  genItems() {
    if (isForceGround) {
      // int random = 1 + new Random().nextInt(4);
      // for (var i = 0; i < items.length; i++) {
      //   AnimatedBalloon item = items[i];
      //   if (item.isDoneGame() && random > 0) {
      //     item.playGame();
      //     random--;
      //   }
      // }
      // for (int i = 0; i < random; i++) {
        // //print('height_screen $height_screen');
        items.add(new AnimatedBalloon(height_screen: height_screen));
      // }
      Timer(Duration(milliseconds: 800), () {
        if (this.mounted) {
          genItems();
          setState(() {});
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      isForceGround = false;
    } else if (state == AppLifecycleState.resumed) {
      isForceGround = true;
      genItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,

      child: Stack(
        children: [...items],
      ),
    );
  }
}
