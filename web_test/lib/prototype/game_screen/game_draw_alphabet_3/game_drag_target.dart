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

  void loadAlphabetData() {
    stepIndex = screenModel.currentStep;
    allGameData = screenModel.currentGame;
    imageData = allGameData.gameData[stepIndex].items;
    assetFolder = screenModel.localPath + allGameData.gameAssets;
    for (int idx = 0; idx < imageData.length; idx++) {
      isCompleted.add(false);
    }
    imageData.map((item) {
      print(item.type);
      if (item.type == 0) {
        print(item.image);
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
    super.initState();
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

  void callOnDraggableCancelled(ItemModel item, Offset offset) {
    if (isWrongTarget) {
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

  Widget displayDraggable() {
    return Stack(
      children: sourceModel.map((item) {
        return Positioned(
            top: item.position.dy,
            left: item.position.dx,
            child: Draggable(
              data: item.groupId,
              child: item.status == 1
                  ? Container()
                  : AnimationDraggableTap(
                      buttonId: item.id,
                      child: AnimationHitFail(
                        isDisplayAnimation: isHitFail,
                        child: Container(
                          height: item.height * 0.9,
                          width: item.width * 0.9,
                          child: Image.file(
                            File(assetFolder + item.image),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
              feedback: Container(
                height: item.height,
                width: item.width,
                child: Image.file(
                  File(assetFolder + item.image),
                  fit: BoxFit.contain,
                ),
              ),
              childWhenDragging: Container(),
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
          top: item.position.dy,
          left: item.position.dx,
          child: DragTarget<int>(
            builder: (context, candidateData, rejectedData) {
              return item.status == 0
                  ? Container(
                      height: item.height,
                      width: item.width,
                      child: Image.file(File(assetFolder + item.image),
                          fit: BoxFit.contain),
                    )
                  : AnimatedMatchedTarget(
                      child: Container(
                      height: item.height,
                      width: item.width,
                      child: Image.file(
                          File(assetFolder + sourceModel[index].image),
                          fit: BoxFit.contain),
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
              setState(() {
                count++;
                item.status = 1;
                sourceModel[index].status = 1;
              });
              if (count == sourceModel.length) {
                Timer(Duration(milliseconds: 1000), () {
                  screenModel.nextStep();
                });
              }
            },
          ),
        );
      }).toList(),
    );
  }

  List<Widget> displayScreen() {
    List<Widget> widgets = [];
    widgets.add(displayTarget());
    widgets.add(displayDraggable());
    widgets.add(BasicItem());
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                )));
  }
}
