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
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/animated_matched_target.dart';
import 'package:web_test/widgets/animation_draggable_tap.dart';
import 'package:web_test/widgets/animation_hit_fail.dart';
import 'package:web_test/widgets/basic_item.dart';
import 'package:web_test/widgets/tutorial_widget.dart';

class CalculateGame extends StatefulWidget {
  _CalculateGameState createState() => _CalculateGameState();
}

class _CalculateGameState extends State<CalculateGame> {
  List data;
  List<ItemModel> itemData = [];
  List<ItemModel> sourceModel = [];
  List<ItemModel> targetModel = [];
  List<ItemModel> normalItemModel = [];
  List<int> draggableKey = [];
  List<int> targetKey = [];
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
  bool isDisplayTutorialWidget=false;

  void getGameData() {
    stepIndex = screenModel.currentStep;
    ParentGameModel allGameData = screenModel.currentGame;
    for (int idx = 0;
        idx < allGameData.gameData[stepIndex].items.length;
        idx++) {
      itemData.add(allGameData.gameData[stepIndex].items[idx].copy());
    }
    assetFolder = screenModel.localPath + allGameData.gameAssets;
    for (int index = 0; index < itemData.length; index++) {
      if (itemData[index].type == 0) {
        // print(itemData[index].status);
        setState(() {
          targetModel.add(itemData[index]);
          targetKey.add(itemData[index].id);
        });
      }
      if (itemData[index].type == 1) {
        sourceModel.add(itemData[index]);
        draggableKey.add(itemData[index].id);
      }
      if (itemData[index].type == 2) {
        normalItemModel.add(itemData[index]);
      }
    }
  }

  @override
  void initState() {
    print('InitState');
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
    bonusHeight = (screenHeight * 1.2 - 111 * ratio) / 2;
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
      item.position = Offset(offset.dx / ratio, offset.dy / ratio);
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
      item.position = Offset(offset.dx / ratio, offset.dy / ratio);
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
        Positioned(
            top: (screenHeight * 1.2 - 79 * ratio) / 2,
            left: 186 * ratio,
            child: displayNumber(firstElement, 58, 79)),
        Positioned(
            top: (screenHeight * 1.2 - 79 * ratio) / 2,
            left: 367 * ratio,
            child: displayNumber(secondElement, 58, 79)),
        Positioned(
            top: (screenHeight * 1.2 - 62 * ratio) / 2,
            left: 274 * ratio,
            child: Container(
              height: 62 * ratio,
              width: 62 * ratio,
              child: SvgPicture.asset(
                "assets/images/common/plus.svg",
                fit: BoxFit.contain,
              ),
            )),
        Positioned(
            top: (screenHeight * 1.2 - 39 * ratio) / 2,
            left: 456 * ratio,
            child: Container(
              height: 39 * ratio,
              width: 62 * ratio,
              child: SvgPicture.asset(
                "assets/images/common/equal.svg",
                fit: BoxFit.contain,
              ),
            ))
      ],
    );
  }

  Widget displayItemImage(
      double height, double width, String image, int value, bool isScale) {
    if (value == 0) {
      return Container(
        height: height * ratio,
        width: width * ratio,
        child: SvgPicture.file(
          File(image),
          fit: BoxFit.contain,
        ),
      );
    } else {
      return Container(
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
      );
    }
  }

  Widget displayTarget() {
    List<int> targetIndex = Iterable<int>.generate(targetModel.length).toList();
    print(targetIndex.length);
    return Stack(
      children: targetIndex.map((index) {
        ItemModel item = targetModel[index];
        return Positioned(
            top: bonusHeight,
            left: item.position.dx * ratio,
            child: DragTarget<int>(
              builder: (context, candidateData, rejectedData) {
                String fullInitUrl = assetFolder + item.image;
                String fullCompleteUrl = assetFolder + sourceModel[index].image;
                return item.status == 0
                    ? displayItemImage(
                        item.height, item.width, fullInitUrl, 0, false)
                    : AnimatedMatchedTarget(
                        child: displayItemImage(item.height, item.width,
                            fullCompleteUrl, result, true),
                      );
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
                  sourceModel[index].status = 1;
                  targetModel[index].status = 1;
                });
                Timer(Duration(milliseconds: 1500), () {
                  screenModel.nextStep();
                  if(screenModel.currentStep==0){
                    if(timer!=null){
                      timer.cancel();
                    }
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
        if (item.groupId == 0) {
          number = result;
        } else if (randomIndex % 2 == 0) {
          number = firstRandomValue;
        } else {
          number = secondRandomValue;
        }
        randomIndex++;
        return AnimatedPositioned(
            duration: Duration(milliseconds: item.duration),
            top: item.position.dy * ratio,
            left: item.position.dx * ratio,
            child: AnimationDraggableTap(
              child: Draggable(
                data: item.groupId,
                child: AnimationHitFail(
                  isDisplayAnimation: isHitFail,
                  child: item.status == 0
                      ? displayItemImage(
                          item.height, item.width, fullInitUrl, number, false)
                      : Container(),
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
            ));
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
    int groupId;
    for (int index = 0; index < sourceModel.length; index++) {
      ItemModel item = sourceModel[index];
      if (item.status == 0) {
        startPosition = Offset(
            item.position.dx * ratio + item.width / 2 * ratio,
            item.position.dy * ratio + item.height / 2 * ratio );
        groupId = item.groupId;
        break;
      }
    }
    for (int index = 0; index < targetModel.length; index++) {
      ItemModel item = targetModel[index];
      if (item.status == 0 && item.groupId == groupId) {
        endPosition = Offset(item.position.dx * ratio + item.width / 2 * ratio,
            bonusHeight+item.height/2 );
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
    widgets.add(displayNormalItem());
    widgets.add(displayCalculation());
    widgets.add(displayTarget());
    widgets.add(displayDraggable());
    widgets.add(BasicItem());
    widgets.add(displayTutorialWidget());
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    print(targetModel[0].status);
    return Listener(
        onPointerDown: onPointerTap,
        onPointerMove: onPointerTap,
        onPointerUp: onPointerTap,
        child: Scaffold(
          body: itemData.length != 0
              ? Container(
                  color: HexColor('#DE2463'),
                  child: Stack(
                    children: displayScreen(),
                  ))
              : Container(),
        ));
  }
}
