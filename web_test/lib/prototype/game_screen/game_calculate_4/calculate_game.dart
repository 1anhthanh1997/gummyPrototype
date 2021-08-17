import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:web_test/config/id_config.dart';
import 'package:web_test/model/item_model.dart';
import 'package:web_test/model/parent_game_model.dart';
import 'package:web_test/prototype/game_screen/game_calculate_4/draggable_scale.dart';
import 'package:web_test/prototype/game_screen/game_calculate_4/translate_calculation.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/animated_matched_target.dart';
import 'package:web_test/widgets/animation_draggable_tap.dart';
import 'package:web_test/widgets/animation_hit_fail.dart';
import 'package:web_test/widgets/basic_item.dart';
import 'package:web_test/widgets/fade_animation.dart';
import 'package:web_test/widgets/skip_screen.dart';
import 'package:web_test/widgets/tutorial/tutorial_widget.dart';

class CalculateGame extends StatefulWidget {
  _CalculateGameState createState() => _CalculateGameState();
}

class _CalculateGameState extends State<CalculateGame> {
  List<ItemModel> itemData = [];
  List<ItemModel> sourceModel = [];
  List<ItemModel> targetModel = [];
  List<ItemModel> normalItemModel = [];
  List<ItemModel> sourceImage = [];
  List<ItemModel> targetImage = [];
  String assetFolder = '';
  bool isHitFail = false;
  bool isWrongTarget = false;
  ScreenModel screenModel;
  double screenWidth;
  double screenHeight;
  double ratio;
  double bonusHeight;
  int firstElement;
  int secondElement;
  int result;
  int firstRandomValue;
  int secondRandomValue;
  int randomIndex = 0;
  final debug = true;
  int stepIndex;
  Timer timer;
  bool isDisplayTutorialWidget = false;
  bool isDisplaySkipScreen = false;
  bool isScale = true;
  bool isFinishStep = false;
  int translateTime = 500;
  ParentGameModel allGameData;

  void getGameData() {
    stepIndex = screenModel.currentStep;
    allGameData = screenModel.currentGame;
    for (int idx = 0;
        idx < allGameData.gameData[stepIndex].items.length;
        idx++) {
      itemData.add(allGameData.gameData[stepIndex].items[idx].copy());
    }
    assetFolder = screenModel.localPath + allGameData.gameAssets;
    for (int index = 0; index < itemData.length; index++) {
      if (itemData[index].type == 0) {
        setState(() {
          targetImage.add(itemData[index]);
        });
      }
      if (itemData[index].type == 1) {
        sourceImage.add(itemData[index]);
      }
      if (itemData[index].type == 2) {
        normalItemModel.add(itemData[index]);
      }
    }
    Random random = Random();
    int chosenIndex = random.nextInt(3);

    for (int index = 0; index < 3; index++) {
      Random secondRandom = Random();
      ItemModel item = sourceImage[secondRandom.nextInt(sourceImage.length)];
      sourceModel.add(item);
      sourceImage.remove(item);
    }

    for (int index = 0; index < targetImage.length; index++) {
      if (targetImage[index].groupId == sourceModel[chosenIndex].groupId) {
        targetModel.add(targetImage[index]);
        break;
      }
    }
  }

  void resetState() {
    itemData = [];
    sourceModel = [];
    targetModel = [];
    normalItemModel = [];
    sourceImage = [];
    targetImage = [];
    setState(() {
      isScale = false;
    });
    Timer(Duration(milliseconds: 500), () {
      isScale = true;
      setState(() {
        isFinishStep = false;
        translateTime = 0;
      });
    });
    setState(() {
      isScale = true;
    });
    genElement();
    _initializeTimer();
  }

  @override
  void initState() {
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
    genElement();
    getGameData();
    _initializeTimer();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenHeight = screenModel.getScreenHeight();
    screenWidth = screenModel.getScreenWidth();
    ratio = screenModel.getRatio();
    for (int index = 0; index < sourceModel.length; index++) {
      ItemModel item = sourceModel[index];
      sourceModel[index].position =
          Offset(259 * ratio + 341 / 3 * index * ratio, 43 * ratio);
    }
    bonusHeight = (screenHeight * 1.2 - 111 * ratio) / 2;
    isDisplaySkipScreen = screenModel.isDisplaySkipScreen;
    Timer(Duration(milliseconds: 800), () {
      setState(() {
        isDisplaySkipScreen = false;
      });
      screenModel.isDisplaySkipScreen = false;
    });
  }

  @override
  void dispose() {
    if (timer != null) {
      timer.cancel();
    }
    super.dispose();
  }

  void _initializeTimer() {
    timer = Timer.periodic(new Duration(seconds: 7), (timer) {
      setState(() {
        isDisplayTutorialWidget = true;
      });
    });
  }

  void onPointerTap(PointerEvent details) {
    if (!timer.isActive) {
      return;
    }
    timer.cancel();
    setState(() {
      isDisplayTutorialWidget = false;
    });
    _initializeTimer();
  }

  void genElement() {
    Random random = new Random();
    int firstItem = random.nextInt(8) + 1;
    int secondItem = random.nextInt(9 - firstItem) + 1;
    firstRandomValue = firstItem + secondItem;
    secondRandomValue = firstRandomValue;
    while (firstRandomValue == secondRandomValue ||
        firstRandomValue == firstItem + secondItem ||
        secondRandomValue == firstItem + secondItem) {
      firstRandomValue = random.nextInt(8) + 1;
      secondRandomValue = random.nextInt(8) + 1;
    }
    setState(() {
      firstElement = firstItem;
      secondElement = secondItem;
      result = firstItem + secondItem;
    });
  }

  double getBiggerSpace(Offset offsetSource, Offset offset) {
    double verticalSpace = offsetSource.dy - offset.dy > 0
        ? offsetSource.dy - offset.dy
        : offset.dy - offsetSource.dy;
    double horizontalSpace = offsetSource.dx - offset.dx > 0
        ? offsetSource.dx - offset.dx
        : offset.dx - offsetSource.dx;
    double denta =
        verticalSpace > horizontalSpace ? verticalSpace : horizontalSpace;
    return denta;
  }

  int editValue(int val) {
    if (val >= 0)
      return val;
    else
      return -1 * val;
  }

  void onDraggableCancelled(ItemModel item, Offset offset) {
    if (isWrongTarget) {
      screenModel.playGameItemSound(WRONG_COLOR);
      Offset offsetSource = item.position;
      item.position = Offset(offset.dx, offset.dy);
      setState(() {
        isHitFail = true;
      });
      Timer(Duration(milliseconds: 200), () {
        setState(() {
          isHitFail = false;
          isWrongTarget = false;
        });
      });
      Timer(Duration(milliseconds: 800), () {
        double denta = getBiggerSpace(offsetSource, offset);
        if (denta < 200 && item.status == 0) {
          denta = 200;
        }
        item.duration = editValue(denta.toInt());
        item.position = offsetSource;
        setState(() {});
      });
    } else {
      Offset offsetSource = item.position;
      item.position = Offset(offset.dx, offset.dy);
      setState(() {});
      Timer(Duration(milliseconds: 50), () {
        double denta = getBiggerSpace(offsetSource, offset);
        if (denta < 200 && item.status == 0) {
          denta = 200;
        }
        item.duration = editValue(denta.toInt());
        item.position = offsetSource;
        setState(() {});
      });
    }
  }

  int getSourceIndex(int groupId) {
    for (int index = 0; index < sourceModel.length; index++) {
      if (sourceModel[index].groupId == groupId) {
        return index;
      }
    }
  }

  String getNumberLink(int value) {
    switch (value) {
      case 1:
        return 'assets/images/common/number/one.svg';
      case 2:
        return 'assets/images/common/number/two.svg';
      case 3:
        return 'assets/images/common/number/three.svg';
      case 4:
        return 'assets/images/common/number/four.svg';
      case 5:
        return 'assets/images/common/number/five.svg';
      case 6:
        return 'assets/images/common/number/six.svg';
      case 7:
        return 'assets/images/common/number/seven.svg';
      case 8:
        return 'assets/images/common/number/eight.svg';
      case 9:
        return 'assets/images/common/number/nine.svg';
    }
  }

  Widget displayNumber(int number, double width, double height) {
    return Container(
      // color: Colors.red,
      height: height * ratio,
      width: width * ratio,
      child: SvgPicture.asset(getNumberLink(number), fit: BoxFit.contain),
    );
  }

  Widget displayCalculation() {
    return Stack(
      children: [
        AnimatedPositioned(
            top: (screenHeight * 1.2 - 79 * ratio) / 2+25*ratio,
            left: 186 * ratio+5*ratio,
            duration: Duration(milliseconds: translateTime),
            child: FadeAnimation(
                delayTime: 0,
                beginValue: 0.0,
                endValue: 1.0,
                isFade: !isFinishStep,
                time: 500,
                // child: TranslateCalculation(
                //     isScale: !isFinishStep,
                //     beginValue: 12.5,
                //     endValue: -12.5 * ratio,
                //     curve: Curves.easeOutQuad,
                //     time: 250,
                //     delayTime: 0,
                child: displayNumber(firstElement, 58, 79))),
        // ),
        AnimatedPositioned(
            duration: Duration(milliseconds: translateTime),
            top: (screenHeight * 1.2 - 79 * ratio) / 2+25*ratio,
            left: 367 * ratio+5*ratio,
            child: FadeAnimation(
                delayTime: 400,
                beginValue: 0.0,
                endValue: 1.0,
                isFade: !isFinishStep,
                time: 500,
                // child: TranslateCalculation(
                //     isScale: !isFinishStep,
                //     beginValue: 12.5,
                //     endValue: -12.5 * ratio,
                //     curve: Curves.easeOutQuad,
                //     time: 250,
                //     delayTime: 400,
                child: displayNumber(secondElement, 58, 79))
            // )
            ),
        AnimatedPositioned(
            duration: Duration(milliseconds: translateTime),
            top: (screenHeight * 1.2 - 62 * ratio) / 2+25*ratio,
            left: 274 * ratio+5*ratio,
            child: FadeAnimation(
                delayTime: 200,
                beginValue: 0.0,
                endValue: 1.0,
                isFade: !isFinishStep,
                time: 500,
                // child: TranslateCalculation(
                //     isScale: !isFinishStep,
                //     beginValue: 12.5,
                //     endValue: -12.5 * ratio,
                //     curve: Curves.easeOutQuad,
                //     time: 250,
                //     delayTime: 200,
                child: Container(
                  height: 62 * ratio,
                  width: 62 * ratio,
                  child: SvgPicture.asset(
                    "assets/images/common/plus.svg",
                    fit: BoxFit.contain,
                  ),
                ))
            // )
            ),
        AnimatedPositioned(
            duration: Duration(milliseconds: translateTime),
            top: (screenHeight * 1.2 - 39 * ratio) / 2+25*ratio,
            left: 456 * ratio+5*ratio,
            child: FadeAnimation(
                delayTime: 600,
                beginValue: 0.0,
                endValue: 1.0,
                isFade: !isFinishStep,
                time: 500,
                // child: TranslateCalculation(
                //     isScale: !isFinishStep,
                //     beginValue: 12.5,
                //     endValue: -12.5 * ratio,
                //     curve: Curves.easeOutQuad,
                //     time: 250,
                //     delayTime: 600,
                child: Container(
                  height: 39 * ratio,
                  width: 62 * ratio,
                  child: SvgPicture.asset(
                    "assets/images/common/equal.svg",
                    fit: BoxFit.contain,
                  ),
                )))
        // )
      ],
    );
  }

  Widget displayItemImage(
      double height, double width, String image, int value, bool isScale) {
    if (value == 0) {
      return Container(
        height: 111 * ratio,
        width: 130 * ratio,
        alignment: Alignment.center,
        child: Container(
          height: height * ratio,
          width: width * ratio,
          child: Image.file(
            File(image),
            fit: BoxFit.contain,
          ),
        ),
      );
    } else {
      return Container(
        height: 96 * ratio,
        width: 341 / 3 * ratio,

        alignment: Alignment.center,
        child: Container(
          height: height * ratio,
          width: width * ratio,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: FileImage(File(image)), fit: BoxFit.contain)),
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 20 * ratio),
          child: isScale
              ? displayNumber(value, 29 * 1.3, 36 * 1.3)
              : displayNumber(value, 29, 36),
        ),
      );
    }
  }

  Widget displayTarget() {
    List<int> targetIndex = Iterable<int>.generate(targetModel.length).toList();
    return Stack(
      children: targetIndex.map((index) {
        ItemModel item = targetModel[index];
        int sourceIndex = getSourceIndex(item.groupId);
        return Positioned(
            top: bonusHeight+25*ratio,
            left: item.position.dx * ratio+40*ratio,
            child: DragTarget<int>(
              builder: (context, candidateData, rejectedData) {
                String fullInitUrl = assetFolder + item.image;
                String fullCompleteUrl =
                    assetFolder + sourceModel[sourceIndex].image;
                return item.status == 0
                    ? FadeAnimation(
                        delayTime: 1000,
                        beginValue: 0.0,
                        endValue: 1.0,
                        isFade: !isFinishStep,
                        time: 500,
                        // child: TranslateCalculation(
                        //   isScale: true,
                        //   beginValue: 12.5,
                        //   endValue: -12.5 * ratio,
                        //   curve: Curves.easeOutQuad,
                        //   time: 250,
                        //   delayTime: 1000,
                        child: displayItemImage(item.height * 1.4,
                            item.width * 1.4, fullInitUrl, 0, false),
                      )
                    // )
                    : AnimatedMatchedTarget(
                        child: FadeAnimation(
                        delayTime: 1000,
                        beginValue: 1.0,
                        endValue: 0.0,
                        isFade: isFinishStep,
                        time: 500,
                        child: displayItemImage(item.height * 1.4,
                            item.width * 1.4, fullCompleteUrl, result, true),
                      ));
              },
              onWillAccept: (data) {
                return data == item.groupId;
              },
              onLeave: (data) {
                setState(() {
                  isWrongTarget = true;
                });
              },
              onAccept: (data) {
                screenModel.playGameItemSound(JIGSAW_DROP);
                screenModel.endPositionId = item.id;
                screenModel.endPosition = item.position;
                setState(() {
                  sourceModel[sourceIndex].status = 1;
                  targetModel[index].status = 1;
                  isScale = false;
                });
                if (screenModel.currentStep <
                    screenModel.currentGame.gameData.length - 1) {
                  setState(() {
                    isFinishStep = true;
                  });
                }
                Timer(Duration(milliseconds: 2000), () {
                  if (screenModel.currentStep <
                      screenModel.currentGame.gameData.length - 1) {
                    screenModel.nextStep();
                    if (timer != null) {
                      timer.cancel();
                    }
                    resetState();
                    getGameData();
                    for (int index = 0; index < sourceModel.length; index++) {
                      ItemModel item = sourceModel[index];
                      sourceModel[index].position =
                          Offset(259 * ratio + 341 / 3 * index * ratio, 43 * ratio);
                    }
                  } else {
                    if (timer != null) {
                      timer.cancel();
                    }
                    screenModel.setContext(context);
                    screenModel.nextStep();
                  }
                });
              },
            ));
      }).toList(),
    );
  }

  Widget displayDraggable() {
    List<int> sourceIndex = Iterable<int>.generate(sourceModel.length).toList();
    int randomIndex = 0;
    return Stack(
      children: sourceIndex.map((index) {
        int number;
        ItemModel item = sourceModel[index];
        String fullInitUrl = assetFolder + item.image;
        if (item.groupId == targetModel[0].groupId) {
          number = result;
        } else if (randomIndex % 2 == 0) {
          number = firstRandomValue;
          randomIndex++;
        } else {
          number = secondRandomValue;
          randomIndex++;
        }
        return AnimatedPositioned(
            duration: Duration(milliseconds: item.duration),
            top: item.position.dy,
            left: item.position.dx,
            child: AnimationDraggableTap(
                child: DraggableScale(
              isScale: !isFinishStep ? true : isScale,
              beginValue: 0.0,
              endValue: 1.0,
              curve: Curves.easeOutBack,
              delayTime: 500 * (index + 1),
              child: Draggable(
                data: item.groupId,
                child: AnimationHitFail(
                  isDisplayAnimation: isHitFail,
                  child: item.status == 0
                      ? displayItemImage(
                          item.height, item.width, fullInitUrl, number, false)
                      : Container(),
                  // ),
                ),
                feedback: displayItemImage(
                    item.height, item.width, fullInitUrl, number, false),
                childWhenDragging: Container(),
                onDragStarted: () {
                  screenModel.playGameItemSound(PICK);
                  screenModel.startPositionId = item.id;
                  screenModel.startPosition = item.position;
                  item.duration = 0;
                },
                maxSimultaneousDrags: 1,
                onDraggableCanceled: (velocity, offset) {
                  screenModel.endPositionId = -1;
                  screenModel.endPosition = offset;
                  screenModel.logDragEvent(false);
                  onDraggableCancelled(item, offset);
                },
              ),
            )));
      }).toList(),
    );
  }

  Widget displayNormalItem() {
    return Stack(
        children: normalItemModel.map((item) {
      return Positioned(
          top: item.position.dy * ratio,
          left: item.position.dx * ratio,
          child: Container(
            height: item.height * ratio,
            width: item.width * ratio,
            child: SvgPicture.file(
              File(assetFolder + item.image),
              fit: BoxFit.contain,
            ),
          ));
    }).toList());
  }

  Widget displayTutorialWidget() {
    Offset startPosition = Offset(0, 0);
    Offset endPosition = Offset(0, 0);
    for (int index = 0; index < sourceModel.length; index++) {
      ItemModel item = sourceModel[index];
      if (item.groupId == targetModel[0].groupId) {
        print(index);
        print(197 * ratio + 419 / 3 * index * ratio + 419 / 6 * ratio);
        print(item.position.dx);
        startPosition = Offset(item.position.dx + 341 / 6 * ratio,
            item.position.dy + item.height / 2 * ratio);
        break;
      }
    }

    ItemModel item = targetModel[0];
    endPosition = Offset(item.position.dx * ratio + 110 / 2 * ratio+25*ratio,
        bonusHeight + 110 / 2 * ratio+40*ratio);

    return isDisplayTutorialWidget
        ? TutorialWidget(
            startPosition: startPosition,
            endPosition: endPosition,
            onCompleted: () {
              Timer(Duration(milliseconds: 200), () {
                setState(() {
                  isDisplayTutorialWidget = false;
                });
              });
            },
          )
        : Container();
  }

  Widget displayNoteBackground() {
    String imageName = 'note_background.png';
    return Stack(
      children: [
        Positioned(
            left: 67 * ratio,
            top: screenHeight / 2 - 331 * ratio / 2 + 4 * ratio,
            child: Container(
              height: 331 * ratio,
              width: 681 * ratio,
              child: Image.file(File(assetFolder + imageName)),
            )),
      ],
    );
  }

  List<Widget> displayScreen() {
    List<Widget> widgets = [];
    widgets.add(displayNoteBackground());
    widgets.add(displayNormalItem());
    widgets.add(displayCalculation());
    widgets.add(displayTarget());
    widgets.add(displayDraggable());
    widgets.add(BasicItem());
    if (isDisplaySkipScreen) {
      widgets.add(SkipScreen());
    }
    widgets.add(displayTutorialWidget());
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerDown: onPointerTap,
        onPointerMove: onPointerTap,
        onPointerUp: onPointerTap,
        child: Scaffold(
          body: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: FileImage(File(assetFolder +
                          allGameData.gameData[stepIndex].background)),
                      fit: BoxFit.fill)),
              child: Stack(
                children: displayScreen(),
              )),
        ));
  }
}
