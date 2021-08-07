import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:web_test/prototype/general_screen/tutorial_animal.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/slider/custom_slider.dart';

import 'lite_rolling_switch.dart';

class BasicItem extends StatefulWidget {
  _BasicItemState createState() => _BasicItemState();
}

class _BasicItemState extends State<BasicItem> {
  ScreenModel screenModel;
  double screenHeight;
  double screenWidth;
  double ratio;

  @override
  void initState() {
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
    screenModel.logBasicEvent(
        'enter_step_${screenModel.currentStep}_game_${screenModel.currentGameId}',
        screenModel.currentGameId,
        screenModel.currentStep,
        'enter_game');
    super.initState();
  }

  @override
  void didChangeDependencies() {
    screenWidth = screenModel.getScreenWidth();
    screenHeight = screenModel.getScreenHeight();
    ratio = screenModel.getRatio();
    super.didChangeDependencies();
  }

  Widget displayStep() {
    List<int> imageIndex =
        Iterable<int>.generate(screenModel.currentGame.gameData.length)
            .toList();
    return Stack(
      children: imageIndex.map((index) {
        return Positioned(
            top: 9 * ratio,
            left: screenWidth - 33 * ratio - 18.0 * ratio * (screenModel.currentGame.gameData.length-1-index),
            child: index == screenModel.currentStep
                ? Container(
                    height: 18 * ratio,
                    width: 18 * ratio,
                    child: SvgPicture.asset(
                      'assets/images/common/check.svg',
                      fit: BoxFit.contain,
                    ))
                : Container(
                    height: 18 * ratio,
                    width: 18 * ratio,
                    alignment: Alignment.center,
                    child: Container(
                      height: 10 * ratio,
                      width: 10 * ratio,
                      child: SvgPicture.asset(
                        'assets/images/common/uncheck.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ));
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TutorialAnimals(
          tutorialImage: 'assets/images/common/dog.svg',
        ),
        CustomSlider(),
        displayStep()
      ],
    );
  }
}
