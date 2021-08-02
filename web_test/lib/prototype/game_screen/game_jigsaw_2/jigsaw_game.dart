import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_test/config/id_config.dart';
import 'package:web_test/model/item_model.dart';
import 'package:web_test/model/parent_game_model.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/animated_matched_target.dart';
import 'package:web_test/widgets/basic_item.dart';
import 'package:web_test/widgets/scale_animation.dart';
import 'package:web_test/widgets/skip_screen.dart';
import 'package:web_test/widgets/tutorial/tutorial_widget.dart';

class JigsawGame extends StatefulWidget {
  _JigsawGameState createState() => _JigsawGameState();
}

class _JigsawGameState extends State<JigsawGame> {
  List<ItemModel> imageData = [];
  double bonusHeight = 0;
  double ratio;
  bool isWrongTarget = false;
  String assetFolder;
  ParentGameModel allGameData;
  List<ItemModel> sourceModel = [];
  List<ItemModel> targetModel = [];
  int count = 0;
  ScreenModel screenModel;
  int stepIndex;
  double screenWidth;
  double screenHeight;
  double objectHeight;
  bool isDisplayTutorialWidget = false;
  Timer timer;
  bool isComplete = false;
  bool isScaleCompletedImage = false;
  bool isDisplayCompleteImage = false;
  Timer firstTimer;
  Timer secondTimer;
  Timer thirdTimer;
  bool isDisplaySkipScreen;

  void loadAlphabetData() {
    targetModel = [];
    imageData = [];
    sourceModel = [];
    count = 0;
    stepIndex = screenModel.currentStep;
    allGameData = screenModel.currentGame;
    for (int idx = 0;
        idx < allGameData.gameData[stepIndex].items.length;
        idx++) {
      imageData.add(allGameData.gameData[stepIndex].items[idx].copy());
    }
    objectHeight = allGameData.gameData[stepIndex].height;
    print(objectHeight);

    assetFolder = screenModel.localPath +
        allGameData.gameAssets +
        allGameData.gameData[stepIndex].stepAssets;
    // assetFolder =
    //     allGameData.gameAssets + allGameData.gameData[stepIndex].stepAssets;

    for (int index = 0; index < imageData.length; index++) {
      if (imageData[index].type == 0) {
        setState(() {
          targetModel.add(imageData[index]);
        });
      }
      if (imageData[index].type == 1) {
        sourceModel.add(imageData[index]);
      }
    }
  }

  @override
  void initState() {
    print('InitState');
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
    loadAlphabetData();
    _initializeTimer();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    screenWidth = screenModel.getScreenWidth();
    screenHeight = screenModel.getScreenHeight();
    ratio = screenModel.getRatio();
    bonusHeight = (screenHeight - objectHeight * ratio) / 2 - 44 * ratio;
    isDisplaySkipScreen=screenModel.isDisplaySkipScreen;
    Timer(Duration(milliseconds: 1100), () {
      setState(() {
        isDisplaySkipScreen = false;
      });
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (timer != null) {
      timer.cancel();
    }
    if (firstTimer != null) {
      firstTimer.cancel();
    }
    if (secondTimer != null) {
      secondTimer.cancel();
    }
    if (thirdTimer != null) {
      thirdTimer.cancel();
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
    setState(() {
      isDisplayTutorialWidget = false;
    });
    timer.cancel();
    _initializeTimer();
  }

  void bringToFront(ItemModel chosenItem) {
    for (int idx = 0; idx < sourceModel.length; idx++) {
      if (sourceModel[idx].id == chosenItem.id) {
        sourceModel.removeAt(idx);
        break;
      }
    }
    sourceModel.add(chosenItem);
    setState(() {});
  }

  void setCompletedStatus(ItemModel chosenTarget) {
    chosenTarget.status = 1;
    for (int idx = 0; idx < sourceModel.length; idx++) {
      if (sourceModel[idx].groupId == chosenTarget.groupId) {
        sourceModel[idx].status = 1;
        break;
      }
    }
    setState(() {});
  }

  Widget displayShadow() {
    return Stack(
      children: imageData.map((item) {
        return item.type == 2
            ? Positioned(
                top: item.position.dy * ratio + bonusHeight,
                left: item.position.dx * ratio,
                child: Container(
                    height: item.height * ratio,
                    width: item.width * ratio,
                    child: Image.file(
                      File(assetFolder + item.image),
                      fit: BoxFit.contain,
                    )))
            : Container();
      }).toList(),
    );
  }

  Widget displayCompletedImage() {
    if (isScaleCompletedImage) {
      screenModel.playGameItemSound(CORRECT);
    }
    return Stack(
      children: imageData.map((item) {
        return item.type == 3
            ? Positioned(
                top: item.position.dy * ratio + bonusHeight,
                left: item.position.dx * ratio,
                child: Opacity(
                    opacity: isDisplayCompleteImage ? 1.0 : 0.0,
                    child: ScaleAnimation(
                      beginValue: 1.0,
                      endValue: 1.15,
                      isScale: isScaleCompletedImage,
                      time: 200,
                      curve: Curves.easeOutBack,
                      child: Container(
                          height: item.height * ratio,
                          width: item.width * ratio,
                          child: Image.file(
                            File(assetFolder + item.image),
                            fit: BoxFit.contain,
                          )),
                    )))
            : Container();
      }).toList(),
    );
  }

  Widget displayDraggable() {
    return Stack(
      children: sourceModel.map((item) {
        return Positioned(
            top: item.position.dy * ratio + bonusHeight,
            left: item.position.dx * ratio,
            child: Draggable(
              data: item.groupId,
              child: item.status == 0
                  ? Container(
                      height: item.height * 0.9 * ratio,
                      width: item.width * 0.9 * ratio,
                      child: Image.file(
                        File(assetFolder + item.image),
                        fit: BoxFit.contain,
                      ))
                  : Container(),
              feedback: Container(
                height: item.height * ratio,
                width: item.width * ratio,
                child: Image.file(
                  File(assetFolder + item.image),
                  fit: BoxFit.contain,
                ),
              ),
              onDragStarted: () {
                screenModel.playGameItemSound(PICK);
                screenModel.startPositionId = item.id;
                screenModel.startPosition = Offset(item.position.dx * ratio,
                    item.position.dy * ratio + bonusHeight);
              },
              childWhenDragging: Container(),
              onDragEnd: (details) {
                bringToFront(item);
              },
              onDraggableCanceled: (velocity, offset) {
                screenModel.endPositionId = -1;
                screenModel.endPosition = offset;
                screenModel.logDragEvent(false);
                item.position = Offset(
                    offset.dx / ratio, (offset.dy - bonusHeight) / ratio);
                setState(() {});
              },
            ));
      }).toList(),
    );
  }

  Widget displayTarget() {
    return Stack(
      children: targetModel.map((item) {
        return Positioned(
            top: item.position.dy * ratio + bonusHeight,
            left: item.position.dx * ratio,
            child: DragTarget<int>(
              builder: (context, candidateData, rejectedData) {
                return isComplete
                    ? ScaleAnimation(
                        delayTime: 150 * targetModel.indexOf(item),
                        child: Container(
                            height: item.height * ratio,
                            width: item.width * ratio,
                            child: Image.file(
                              File(assetFolder + item.image),
                              fit: BoxFit.contain,
                            )),
                        beginValue: 1.0,
                        endValue: 1.2,
                        isReverse: true,
                        isScale: true,
                        time: 200,
                      )
                    : item.status == 0
                        ? Container(
                            height: item.height * ratio,
                            width: item.width * ratio,
                          )
                        : AnimatedMatchedTarget(
                            child: Container(
                                height: item.height * ratio,
                                width: item.width * ratio,
                                child: Image.file(
                                  File(assetFolder + item.image),
                                  fit: BoxFit.contain,
                                )));
              },
              onWillAccept: (data) {
                return data == item.groupId;
              },
              onAccept: (data) {
                screenModel.playGameItemSound(JIGSAW_DROP);
                screenModel.endPositionId = item.id;
                screenModel.endPosition =
                    Offset(item.position.dx * ratio, item.position.dy * ratio);
                screenModel.logDragEvent(true);
                setCompletedStatus(item);
                if (count == sourceModel.length - 1) {
                  firstTimer = Timer(Duration(milliseconds: 500), () {
                    setState(() {
                      isComplete = true;
                    });
                  });
                  secondTimer = Timer(Duration(milliseconds: 2000), () {
                    setState(() {
                      isDisplayCompleteImage = true;
                      isScaleCompletedImage = true;
                    });
                  });

                  thirdTimer = Timer(
                      Duration(milliseconds: 3000 + 200 * targetModel.length),
                      () {
                    bool isLoadNextStep = false;
                    if (screenModel.currentStep <
                        screenModel.currentGame.gameData.length - 1) {
                      isLoadNextStep = true;
                    }

                    print(screenModel.currentStep);
                    if (!isLoadNextStep) {
                      if (timer != null) {
                        timer.cancel();
                      }
                      screenModel.nextStep();
                    } else {
                      screenModel.nextStep();
                      loadAlphabetData();
                      setState(() {
                        isDisplayCompleteImage = false;
                        isComplete = false;
                        isScaleCompletedImage = false;
                      });
                    }
                  });
                } else {
                  setState(() {
                    count++;
                  });
                }
              },
            ));
      }).toList(),
    );
  }

  Widget displayTutorialWidget() {
    Offset startPosition = Offset(0, 0);
    Offset endPosition = Offset(0, 0);
    int groupId;
    for (int index = 0; index < sourceModel.length; index++) {
      ItemModel item = sourceModel[index];
      if (item.status == 0) {
        startPosition = Offset(
            item.position.dx * ratio + item.width / 2 * ratio,
            item.position.dy * ratio + item.height / 2 * ratio + bonusHeight);
        groupId = item.groupId;
        break;
      }
    }
    for (int index = 0; index < targetModel.length; index++) {
      ItemModel item = targetModel[index];
      if (item.status == 0 && item.groupId == groupId) {
        endPosition = Offset(item.position.dx * ratio + item.width / 2 * ratio,
            item.position.dy * ratio + item.height / 2 * ratio + bonusHeight);
        break;
      }
    }

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

  List<Widget> displayScreen() {
    List<Widget> widgets = [];
    if (!isDisplayCompleteImage) {
      widgets.add(displayShadow());
      widgets.add(displayTarget());
      widgets.add(displayDraggable());
    } else {
      widgets.add(displayCompletedImage());
    }
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
                      image: AssetImage(assetFolder +
                          allGameData.gameData[stepIndex].background),
                      fit: BoxFit.fill)),
              child: Stack(
                children: displayScreen(),
              )),
        ));
  }
}
