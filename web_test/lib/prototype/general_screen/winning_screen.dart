import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_test/config/id_config.dart';
import 'package:web_test/prototype/general_screen/balloon_screen/animated_balloon.dart';
import 'package:web_test/prototype/general_screen/balloon_screen/main_balloon_screen.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/animation_draggable_tap.dart';
import 'package:web_test/widgets/slide_animation.dart';

showResultDialog(BuildContext parentContext) async {
  await Future.delayed(Duration(milliseconds: 500));
  showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return WinningScreen(parentContext);
      },
      transitionDuration: Duration(milliseconds: 300),
      barrierDismissible: true,
      barrierLabel: '',
      context: parentContext,
      pageBuilder: (context, animation1, animation2) {});
}

class WinningScreen extends StatefulWidget {
  final BuildContext parentContext;

  WinningScreen(this.parentContext);

  _WinningScreenState createState() => _WinningScreenState();
}

class _WinningScreenState extends State<WinningScreen> {
  ScreenModel screenModel;
  double screenHeight;
  double screenWidth;
  double ratio;

  @override
  void initState() {
    screenModel = Provider.of<ScreenModel>(widget.parentContext);
    screenModel.isFromShowResult = true;
    List<String>winSound=[WIN_STINGER,WIN_STINGER_2,WIN_STINGER_3];
    Random random =Random();
    String chosenSound=winSound[random.nextInt(winSound.length)];
    screenModel.playGameItemSound(chosenSound);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    screenHeight = screenModel.getScreenHeight();
    screenWidth = screenModel.getScreenWidth();
    ratio = screenModel.getRatio();
    super.didChangeDependencies();
  }

  Widget displayNextButton() {
    return Positioned(
        top: screenHeight / 2 - 35 * ratio,
        left: screenWidth - 100 * ratio,
        child: AnimationDraggableTap(
          parentContext: widget.parentContext,
          onTab: () {
            screenModel.playGameItemSound(PLAY_BTN);
            screenModel.nextGame();
            Navigator.pop(context);
          },
          child: SlideAnimation(
            beginValue: 0.0,
            endValue: 15.0 * ratio,
            isReverse: true,
            time: 800,
            child: Container(
              height: 70 * ratio,
              width: 70 * ratio,
              child: Image.asset(
                'assets/images/common/next_game_button.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ));
  }

  List<Widget> displayScreen() {
    List<Widget> widgets = [];
    widgets.add(MainBalloonScreen());
    widgets.add(displayNextButton());
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
          color: Colors.transparent,
          child: Stack(
            children: displayScreen(),
          )),
    );
  }
}
