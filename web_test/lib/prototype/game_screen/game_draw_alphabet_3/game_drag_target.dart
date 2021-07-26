import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_test/model/item_model.dart';
import 'package:web_test/model/parent_game_model.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/animated_matched_target.dart';
import 'package:web_test/widgets/animation_draggable_tap.dart';
import 'package:web_test/widgets/animation_hit_fail.dart';
import 'package:web_test/widgets/basic_item.dart';
import 'package:web_test/widgets/tutorial_widget.dart';

class GameDragTarget extends StatefulWidget {
  _GameDragTargetState createState() => _GameDragTargetState();
}

class _GameDragTargetState extends State<GameDragTarget>
    with TickerProviderStateMixin {
  List<Path> alphabetPath = [];
  List<List<Map>> _alphabetPoint = [];
  String _focusingItem = '';
  String currentColor = '#000000';
  bool isCorrect = false;
  Offset previousPoint = Offset(0, 0);
  bool isColoringFromStart = false;
  Timer deleteTimer;
  Timer secondDeleteTimer;
  Timer thirdDeleteTimer;
  List data;
  List<ItemModel> alphabetData = [];
  List<String> imageLink = [];
  List<Offset> imagePosition = [];
  List<Offset> startPosition = [];
  List<Offset> endPosition = [];
  int currentIndex = 0;
  double bonusHeight = 0;
  List<ItemModel> imageData = [];
  ParentGameModel allGameData;
  String assetFolder;
  List<bool> isCompleted = [];
  List<ItemModel> sourceModel = [];
  List<ItemModel> targetModel = [];
  bool isWrongTarget = false;
  bool isHitFail = false;
  int count = 0;
  ScreenModel screenModel;
  int stepIndex;
  double screenHeight;
  double screenWidth;
  double ratio;
  double firstBonusHeight;
  double secondBonusHeight;
  Timer timer;
  bool isDisplayTutorialWidget=false;

  void loadAlphabetData() {
    stepIndex = screenModel.currentStep;
    allGameData = screenModel.currentGame;
    for (int idx = 0;
        idx < allGameData.gameData[stepIndex].items.length;
        idx++) {
      imageData.add(allGameData.gameData[stepIndex].items[idx].copy());
    }
    assetFolder = screenModel.localPath + allGameData.gameAssets;
    for (int idx = 0; idx < imageData.length; idx++) {
      isCompleted.add(false);
    }
    imageData.map((item) {
      // print(item.type);
      if (item.type == 0) {
        // print(item.image);
        targetModel.add(item);
      } else if (item.type == 1) {
        sourceModel.add(item);
      }
      setState(() {});
    }).toList();

    setState(() {});
  }

  @override
  void initState() {
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
    firstBonusHeight = (screenHeight / 2 - 73 * ratio) / 2 - 69 * ratio;
    secondBonusHeight =
        (screenHeight * 3 / 2 - 73 * ratio) / 2 - 250 * ratio - 50 * ratio;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if(timer!=null){
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
      isDisplayTutorialWidget=false;
    });
    _initializeTimer();
  }

  double getBiggerSpace(Offset offsetSource, Offset offset) {
    double verticalSpace = offsetSource.dy * ratio + bonusHeight - offset.dy > 0
        ? offsetSource.dy * ratio + bonusHeight - offset.dy
        : offset.dy - offsetSource.dy * ratio - bonusHeight;
    double horizontalSpace = offsetSource.dx * ratio - offset.dx > 0
        ? offsetSource.dx * ratio - offset.dx
        : offset.dx - offsetSource.dx * ratio;
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

  void callOnDraggableCancelled(ItemModel item, Offset offset) {
    if (isWrongTarget) {
      Offset offsetSource = item.position;
      item.position =
          Offset(offset.dx / ratio, (offset.dy - firstBonusHeight) / ratio);
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
      item.position =
          Offset(offset.dx / ratio, (offset.dy - firstBonusHeight) / ratio);
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

  Widget displayDraggable() {
    return Stack(
      children: sourceModel.map((item) {
        return AnimatedPositioned(
            top: item.position.dy * ratio + firstBonusHeight,
            left: item.position.dx * ratio,
            duration: Duration(milliseconds: item.duration),
            child: Draggable(
              data: item.groupId,
              child: item.status == 1
                  ? Container()
                  : AnimationDraggableTap(
                      buttonId: item.id,
                      child: AnimationHitFail(
                        isDisplayAnimation: isHitFail,
                        child: Container(
                          height: item.height * 0.9 * ratio,
                          width: item.width * 0.9 * ratio,
                          child: Image.file(
                            File(assetFolder + item.image),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
              feedback: Container(
                height: item.height * ratio,
                width: item.width * ratio,
                child: Image.file(
                  File(assetFolder + item.image),
                  fit: BoxFit.contain,
                ),
              ),
              childWhenDragging: Container(),
              onDragStarted: () {
                screenModel.startPositionId = item.id;
                screenModel.startPosition = item.position;
                item.duration = 0;
              },
              maxSimultaneousDrags: 1,
              onDraggableCanceled: (velocity, offset) {
                callOnDraggableCancelled(item, offset);
              },
            ));
      }).toList(),
    );
  }

  Widget displayTarget() {
    return Stack(
      children: targetModel.map((item) {
        // print(item);
        int index = targetModel.indexOf(item);
        return Positioned(
          top: screenHeight * 3 / 4 - 50 * ratio,
          left: item.position.dx * ratio,
          child: DragTarget<int>(
            builder: (context, candidateData, rejectedData) {
              return item.status == 0
                  ? Container(
                      height: 100 * ratio,
                      width: item.width * ratio,
                      child: Container(
                        child: Image.file(File(assetFolder + item.image),
                            fit: BoxFit.contain),
                      ))
                  : AnimatedMatchedTarget(
                      child: Container(
                          height: 100 * ratio,
                          width: item.width * ratio,
                          child: Container(
                            child: Image.file(
                                File(assetFolder + sourceModel[index].image),
                                fit: BoxFit.contain),
                          )));
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
              setState(() {
                count++;
                item.status = 1;
                sourceModel[index].status = 1;
              });
              if (count == sourceModel.length) {
                Timer(Duration(milliseconds: 1000), () {
                  screenModel.nextStep();
                  if(screenModel.currentStep==screenModel.currentGame.gameData.length-1){
                    if(timer!=null){
                      timer.cancel();
                    }
                  }
                });
              }
            },
          ),
        );
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
            item.position.dy * ratio + item.height / 2 * ratio + firstBonusHeight);
        groupId = item.groupId;
        break;
      }
    }
    for (int index = 0; index < targetModel.length; index++) {
      ItemModel item = targetModel[index];
      if (item.status == 0 && item.groupId == groupId) {
        endPosition = Offset(item.position.dx * ratio + item.width / 2 * ratio,
            screenHeight * 3 / 4 );
        break;
      }
    }
    // print(isDisplayTutorialWidget);

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
    widgets.add(displayTarget());
    widgets.add(displayDraggable());
    widgets.add(BasicItem());
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
            body: imageData.length == 0
                ? Container()
                : Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: FileImage(File(assetFolder +
                                allGameData.gameData[stepIndex].background)),
                            fit: BoxFit.fill)),
                    child: Stack(
                      children: displayScreen(),
                    ))));
  }
}
