import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:web_test/model/item_model.dart';
import 'package:web_test/provider/screen_model.dart';

class TutorialAnimals extends StatefulWidget {
  final String tutorialImage;

  // String state;
  TutorialAnimals({Key key, this.tutorialImage}) : super(key: key);

  @override
  _TutorialAnimalsState createState() => _TutorialAnimalsState();
}

class _TutorialAnimalsState extends State<TutorialAnimals> {
  Offset currentOffset;
  int duration = 0;
  int displaySkip = 0;
  Offset currentDraggableOffset = Offset(-9, 290);
  ScreenModel screenModel;
  double screenWidth;
  double screenHeight;
  double ratio;

  @override
  void initState() {
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    screenWidth = screenModel.getScreenWidth();
    screenHeight = screenModel.getScreenHeight();
    ratio = screenModel.getRatio();
    currentOffset = Offset(-9 * ratio, screenHeight - 85 * ratio);
    super.didChangeDependencies();
  }

  void onDraggableCancelled(Offset offset) {
    setState(() {
      displaySkip = 0;
    });
    Offset offsetSource;
    if (offset.dx < screenWidth / 2 - 49 * ratio) {
      offsetSource = Offset(-9 * ratio, screenHeight - 85 * ratio);
    } else {
      offsetSource =
          Offset(screenWidth - 89 * ratio, screenHeight - 85 * ratio);
    }

    currentOffset = offset;
    print(offsetSource);
    setState(() {});
    Timer(Duration(milliseconds: 50), () {
      // double denta = screenModel.getBiggerSpace(
      //     offsetSource, offset);
      // if (denta < 200 && status == STATUS_NOT_MATCH) {
      //   denta = 200;
      // }
      duration = 400;
      currentOffset = offsetSource;
      setState(() {});
    });
  }

  double countOpacity(Offset firstOffset, Offset secondOffset) {
    double horizontalMinus = firstOffset.dx - secondOffset.dx - 41;
    double verticalMinus = firstOffset.dy - secondOffset.dy - 41;
    double distance = sqrt(pow(horizontalMinus, 2) + pow(verticalMinus, 2));
    // print(distance / 406);
    if (distance / 406 < 0.3) distance = 0;
    return 1.0 - distance / 406.0 < 0 ? 0 : 1.0 - distance / 406.0;
  }

  double getBiggerValue(double value) {
    return value > 0 ? value : value * -1;
  }

  double countHorizontalDistance(Offset firstOffset, Offset secondOffset) {
    double horizontalMinus = firstOffset.dx - secondOffset.dx;
    // print('dx');
    // print(getBiggerValue(horizontalMinus));
    return horizontalMinus;
  }

  double countVerticalDistance(Offset firstOffset, Offset secondOffset) {
    double verticalMinus = firstOffset.dy - secondOffset.dy;
    // print('dy');
    // print(getBiggerValue(verticalMinus));
    return verticalMinus;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            top: screenHeight -
                79 * ratio -
                countVerticalDistance(
                        currentDraggableOffset,
                        Offset(screenWidth - 52 * ratio,
                            screenHeight - 45 * ratio)) *
                    0.1,
            left: screenWidth -
                86 * ratio -
                countHorizontalDistance(
                        currentDraggableOffset,
                        Offset(screenWidth - 52 * ratio,
                            screenHeight - 45 * ratio)) *
                    0.1,
            child: DragTarget<int>(
              builder: (context, candidateData, rejectedData) {
                return Opacity(
                  opacity: displaySkip == 1
                      ? countOpacity(
                          currentDraggableOffset,
                          Offset(screenWidth - 52 * ratio,
                              screenHeight - 45 * ratio))
                      : 0.0,
                  child: Container(
                      height: 68 * ratio,
                      width: 68 * ratio,
                      child: SvgPicture.asset(
                        'assets/images/common/skip_target.svg',
                        fit: BoxFit.contain,
                      )),
                );
              },
              onWillAccept: (data) {
                return data == 0 && displaySkip == 1;
              },
              onAccept: (data) {
                setState(() {
                  displaySkip = 0;
                  currentOffset = Offset(screenWidth - 89 * ratio, screenHeight - 85 * ratio);
                });
                screenModel.skipGame();
                print('Accept');
              },
            )),
        Positioned(
            top: screenHeight -
                79 * ratio -
                countVerticalDistance(currentDraggableOffset,
                        Offset(60 * ratio, screenHeight - 45 * ratio)) *
                    0.1,
            left: 26 * ratio -
                countHorizontalDistance(currentDraggableOffset,
                        Offset(60 * ratio, screenHeight - 45 * ratio)) *
                    0.1,
            child: DragTarget<int>(
              builder: (context, candidateData, rejectedData) {
                return Opacity(
                    opacity: displaySkip == 2
                        ? countOpacity(currentDraggableOffset,
                            Offset(60 * ratio, screenHeight - 45 * ratio))
                        : 0.0,
                    child: Container(
                      height: 68 * ratio,
                      width: 68 * ratio,
                      child: SvgPicture.asset(
                        'assets/images/common/skip_target.svg',
                        fit: BoxFit.contain,
                      ),
                    ));
              },
              onWillAccept: (data) {
                return data == 0 && displaySkip == 2;
              },
              onAccept: (data) {
                setState(() {
                  displaySkip = 0;
                  currentOffset = Offset(-9 * ratio, screenHeight - 85 * ratio);
                });
                screenModel.skipGame();
                print('Accept');
              },
            )),
        AnimatedPositioned(
          top: currentOffset.dy,
          left: currentOffset.dx,
          duration: Duration(milliseconds: duration),
          curve: Curves.easeOutBack,
          child: Draggable(
            data: 0,
            child: Container(
              height: 98 * ratio,
              width: 98 * ratio,
              child: SvgPicture.asset(
                widget.tutorialImage,
                fit: BoxFit.contain,
              ),
            ),
            feedback: Container(
              height: 98 * ratio,
              width: 98 * ratio,
              child: SvgPicture.asset(
                widget.tutorialImage,
                fit: BoxFit.contain,
              ),
            ),
            childWhenDragging: Container(),
            onDragStarted: () {
              duration = 0;
              setState(() {
                displaySkip =
                    currentOffset.dx < screenWidth / 2 - 49 * ratio ? 1 : 2;
              });
            },
            onDragUpdate: (details) {
              setState(() {
                currentDraggableOffset = Offset(
                    details.globalPosition.dx + 49 * ratio,
                    details.globalPosition.dy + 49 * ratio);
              });
            },
            maxSimultaneousDrags: 1,
            onDraggableCanceled: (velocity, offset) {
              onDraggableCancelled(offset);
            },
          ),
        )
      ],
    );
  }
}
