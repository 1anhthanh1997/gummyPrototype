import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:web_test/config/id_config.dart';
import 'package:web_test/model/item_model.dart';
import 'package:web_test/model/parent_game_model.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/basic_item.dart';
import 'package:web_test/widgets/correct_animation.dart';
import 'package:web_test/widgets/drop_down_animation.dart';
import 'package:web_test/widgets/scale_animation.dart';
import 'package:web_test/widgets/skip_screen.dart';
import 'package:web_test/widgets/tutorial/tutorial_widget.dart';

class ClassifyItem extends StatefulWidget {
  @override
  _ClassifyItemState createState() => _ClassifyItemState();
}

class _ClassifyItemState extends State<ClassifyItem>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  List<bool> isAccepted = [false, false, false, false];
  Offset firstOffset = Offset(812 / 2 - 30, 375 / 2 - 30);
  int durationTime = 0;
  AnimationController controller;
  List<ItemModel> items = [];
  Animation<double> _transAnimation;
  ParentGameModel data;
  List<ItemModel> classifyData = [];
  String assetFolder;
  int step = 0;
  List<bool> isSelected = [false, false];
  ScreenModel screenModel;
  int count = 0;
  int draggableCount = 0;
  int stepIndex;
  double screenWidth;
  double screenHeight;
  double ratio;
  Timer timer;
  bool isDisplayTutorialWidget = false;
  Curve curve;
  int isPlayTargetSound = 0;
  List<ItemModel> sourceModel = [];
  bool isDisplaySkipScreen = false;

  void loadClassifyData() {
    stepIndex = screenModel.currentStep;
    data = screenModel.currentGame;
    for (int idx = 0; idx < data.gameData[stepIndex].items.length; idx++) {
      items.add(data.gameData[stepIndex].items[idx].copy());
    }
    assetFolder = screenModel.localPath + data.gameAssets;
    for (int idx = 0; idx < items.length; idx++) {
      if (items[idx].type == 1) {
        sourceModel.add(items[idx]);
        draggableCount++;
        durationTime = 500;
        curve = Curves.easeOutBack;
      }
    }
    sourceModel.shuffle();
    for (int idx = 0; idx < sourceModel.length; idx++) {
      sourceModel[idx].position = Offset(sourceModel[idx].position.dx,
          -1 * (screenHeight / 6 * (2 * (idx + 1) + 1)));
      durationTime = 500;
      Timer(Duration(milliseconds: 500), () {
        sourceModel[idx].position = Offset(
            sourceModel[idx].position.dx,
            screenHeight -
                screenHeight / 6 * (2 * idx + 1) -
                sourceModel[idx].height / 2);
        // curve=Curves.linear;

        print(sourceModel[idx].position);
        setState(() {});
      });
    }
    print('Break');
    Timer(Duration(milliseconds: 1000 * (items.length - 3)), () {
      curve = Curves.linear;
      setState(() {});
    });
    setState(() {});
  }

  @override
  void initState() {
    print('InitState');
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
    _initializeTimer();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    screenWidth = screenModel.getScreenWidth();
    screenHeight = screenModel.getScreenHeight();
    ratio = screenModel.getRatio();
    this.loadClassifyData();
    _transAnimation = Tween(begin: -500.0 * ratio, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.75, curve: Curves.easeInOutBack),
      ),
    );
    isDisplaySkipScreen=screenModel.isDisplaySkipScreen;
   Timer(Duration(milliseconds: 800),(){
      setState(() {
        isDisplaySkipScreen=false;
      });
    });
    super.didChangeDependencies();

    controller.forward();
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
    setState(() {
      isDisplayTutorialWidget = false;
    });
    timer.cancel();
    _initializeTimer();
  }

  void fallItem(int index) {
    setState(() {
      curve = Curves.easeOutBack;
    });
    print(draggableCount);
    print(index);
    for (int idx = draggableCount - 1; idx > index; idx--) {
      if (sourceModel[idx].status == 0) {
        sourceModel[idx].position = Offset(sourceModel[idx].position.dx,
            sourceModel[idx].position.dy + screenHeight / 3);
        print(sourceModel[idx].position);
      }
    }
    print('Break');
    // Timer(Duration(milliseconds: ))
    // print('Break');
  }

  Widget displayBackground() {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: FileImage(
                File(assetFolder + data.gameData[stepIndex].background),
              ),
              fit: BoxFit.fill)),
    );
  }

  Widget displayNotCompleteDraggable(ItemModel item, int index) {
    return Draggable(
      data: 0,
      child: Container(
        height: item.height * ratio,
        width: item.width * ratio,
        child: Image.file(
          File(assetFolder + item.image),
          fit: BoxFit.contain,
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
        screenModel.playGameItemSound(PICK);
        screenModel.startPositionId = item.id;
        screenModel.startPosition = item.position;
        durationTime = 0;
      },
      onDragUpdate: (details) {
        Offset offset = details.globalPosition;

        if (offset.dx <= screenWidth / 2 - screenWidth / 14 - 30 * ratio) {
          setState(() {
            isPlayTargetSound++;
          });
          if (isPlayTargetSound == 1) {
            // screenModel.playGameItemSound(CHOOSE);
          }
          setState(() {
            isSelected[0] = true;
            isSelected[1] = false;
          });
        } else if (offset.dx >= screenWidth / 2 + screenWidth / 14) {
          setState(() {
            isPlayTargetSound++;
          });
          if (isPlayTargetSound == 1) {
            // screenModel.playGameItemSound(CHOOSE);
          }
          setState(() {
            isSelected[0] = false;
            isSelected[1] = true;
          });
        } else {
          setState(() {
            isPlayTargetSound = 0;
            isSelected[0] = false;
            isSelected[1] = false;
          });
        }
      },
      maxSimultaneousDrags: 1,
      onDraggableCanceled: (velocity, offset) {
        Offset offsetSource;
        screenModel.endPosition = offset;
        if (offset.dx <= screenWidth / 2 - screenWidth / 14 - 30 * ratio &&
            item.groupId == 0) {
          screenModel.endPositionId = 0;
          screenModel.logDragEvent(true);
          offsetSource = Offset(item.endPosition.dx,
              item.endPosition.dy * screenHeight / 375 * 1.1);
          setState(() {
            item.status = 1;
            count++;
          });
        } else if (offset.dx >= screenWidth / 2 + screenWidth / 14 &&
            item.groupId == 1) {
          screenModel.endPositionId = 1;
          screenModel.logDragEvent(true);
          offsetSource = Offset(item.endPosition.dx,
              item.endPosition.dy * screenHeight / 375 * 1.03);
          setState(() {
            item.status = 1;
            count++;
          });
        } else {
          screenModel.playGameItemSound(WRONG_COLOR);
          screenModel.endPositionId = -1;
          screenModel.logDragEvent(false);
          offsetSource = item.position;
        }
        item.position = Offset(offset.dx / ratio, offset.dy);
        setState(() {});
        Timer(Duration(milliseconds: 50), () {
          if (item.status == 1) {
            fallItem(index);
          }
          durationTime = 500;
          item.position = offsetSource;
          Timer(Duration(milliseconds: 1700), () {
            isSelected[item.groupId] = false;
            setState(() {
              curve = Curves.easeOut;
            });
          });
          if (count == draggableCount) {
            Timer(Duration(milliseconds: 2000), () {
              screenModel.nextStep();
              if (screenModel.currentStep ==
                  screenModel.currentGame.gameData.length - 1) {
                if (timer != null) {
                  timer.cancel();
                }
              }
            });
          }
          setState(() {});
        });
      },
    );
  }

  Widget displayCompleteDraggable(ItemModel item, int index) {
    // screenModel.playGameItemSound(SCALE_DOWN);
    return CorrectAnimation(
        isCorrect: item.status == 1,
        delayTime: 500,
        child: Container(
          height: item.height * ratio,
          width: item.width * ratio,
          child: Image.file(
            File(assetFolder + item.image),
            fit: BoxFit.contain,
          ),
        ));
  }

  Widget displayFirstDraggableItem(ItemModel item, int index) {
    Offset position = item.position;
    return AnimatedPositioned(
        top: position.dy,
        left: position.dx * ratio,
        curve: curve,
        duration: Duration(milliseconds: durationTime),
        child: item.status == 1
            ? displayCompleteDraggable(item, index)
            : displayNotCompleteDraggable(item, index));
  }

  Widget displayDraggableItem() {
    List<int> imageIndex = Iterable<int>.generate(sourceModel.length).toList();
    return Container(
        child: Stack(
            children: imageIndex.map((index) {
      ItemModel item = sourceModel[index];
      return displayFirstDraggableItem(item, index);
    }).toList()));
  }

  Widget displayTargetItem() {
    return Stack(
      children: items.map((item) {
        return item.type == 0
            ? Positioned(
                top: (screenHeight - item.height * ratio) / 2,
                left: item.position.dx * ratio,
                child: ScaleAnimation(
                  isScale: isSelected[item.groupId],
                  beginValue: 1.0,
                  endValue: 1.1,
                  time: 50,
                  curve: Curves.easeIn,
                  onTab: () {},
                  child: Container(
                    width: item.width * ratio,
                    height: item.height * ratio,
                    child: Image.file(File(assetFolder + item.image),
                        fit: BoxFit.contain),
                  ),
                ))
            : Container();
      }).toList(),
    );
  }

  // Widget displayNormalItem() {
  //   return Stack(
  //       children: items.map((item) {
  //         print(item.height);
  //     return item.type == 2
  //         ? Positioned(
  //             top: item.position.dy * ratio,
  //             left: item.position.dx * ratio,
  //             child: Container(
  //               width: item.width * ratio,
  //               height: item.height == 375 ? screenHeight : item.height * ratio,
  //               child: Image.file(File(assetFolder + item.image),
  //                   fit: BoxFit.contain),
  //             ))
  //         : Container();
  //   }).toList());
  // }

  Widget displayTutorialWidget() {
    Offset startPosition = Offset(0, 0);
    Offset endPosition = Offset(0, 0);
    int groupId;
    for (int index = 0; index < sourceModel.length; index++) {
      ItemModel item = sourceModel[index];
      if (item.status == 0) {
        startPosition = Offset(
            item.position.dx * ratio + item.width / 2 * ratio,
            item.position.dy + item.height / 2 * ratio);
        if (item.groupId == 0) {
          endPosition = Offset(screenWidth / 4, screenHeight / 2);
        } else {
          endPosition = Offset(screenWidth * 3 / 4, screenHeight / 2);
        }
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

  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerDown: onPointerTap,
        onPointerMove: onPointerTap,
        onPointerUp: onPointerTap,
        child: Scaffold(
          body: Container(
            child: Stack(
              children: [
                displayBackground(),
                // displayNormalItem(),
                displayTargetItem(),
                displayDraggableItem(),
                BasicItem(),
                displayTutorialWidget(),
                isDisplaySkipScreen ? SkipScreen() : Container()
              ],
            ),
          ),
        ));
  }
}
