import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:web_test/model/item_model.dart';
import 'package:web_test/model/parent_game_model.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/basic_item.dart';
import 'package:web_test/widgets/correct_animation.dart';
import 'package:web_test/widgets/scale_animation.dart';

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

  void loadClassifyData() {
    stepIndex = screenModel.currentStep;
    data = screenModel.currentGame;
    for (int idx = 0; idx < data.gameData[stepIndex].items.length; idx++) {
      items.add(data.gameData[stepIndex].items[idx].copy());
    }
    assetFolder = screenModel.localPath + data.gameAssets;
    for (int idx = 0; idx < items.length; idx++) {
      if (items[idx].type == 1) {
        draggableCount++;
        items[idx].position = Offset(items[idx].position.dx,
            screenHeight / 6 * (2 * idx + 1) - items[idx].height / 2);
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    print('InitState');
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
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
    super.didChangeDependencies();

    controller.forward();
  }

  void fallItem(int index) {
    for (int idx = 0; idx < index; idx++) {
      items[idx].position = Offset(items[idx].position.dx * ratio,
          items[idx].position.dy * ratio + 100 * ratio);
    }
  }

  void callOnDraggableCancelled(ItemModel item, int index, Offset offset) {}

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
        child: SvgPicture.file(
          File(assetFolder + item.image),
          fit: BoxFit.contain,
        ),
      ),
      feedback: Container(
        height: item.height * ratio,
        width: item.width * ratio,
        child: SvgPicture.file(
          File(assetFolder + item.image),
          fit: BoxFit.contain,
        ),
      ),
      childWhenDragging: Container(),
      onDragStarted: () {
        screenModel.startPositionId = item.id;
        screenModel.startPosition = item.position;
        durationTime = 0;
      },
      onDragUpdate: (details) {
        Offset offset = details.globalPosition;
        if (offset.dx <= screenWidth / 2 - screenWidth / 14 - 30 * ratio) {
          setState(() {
            isSelected[0] = true;
            isSelected[1] = false;
          });
        } else if (offset.dx >= screenWidth / 2 + screenWidth / 14) {
          setState(() {
            isSelected[0] = false;
            isSelected[1] = true;
          });
        } else {
          setState(() {
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
          offsetSource = Offset(
              item.endPosition.dx, item.endPosition.dy * screenHeight / 375*1.03);
          setState(() {
            item.status = 1;
            count++;
          });
        } else {
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
          durationTime = 300;
          item.position = offsetSource;
          Timer(Duration(milliseconds: 1700), () {
            isSelected[item.groupId] = false;
            setState(() {});
          });
          if (count == draggableCount) {
            Timer(Duration(milliseconds: 2000), () {
              screenModel.nextStep();
            });
          }
          setState(() {});
        });
      },
    );
  }

  Widget displayCompleteDraggable(ItemModel item, int index) {
    return CorrectAnimation(
        isCorrect: item.status == 1,
        child: Container(
          height: item.height * ratio,
          width: item.width * ratio,
          child: SvgPicture.file(
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
        curve: Curves.linear,
        duration: Duration(milliseconds: durationTime),
        child: item.status == 1
            ? displayCompleteDraggable(item, index)
            : displayNotCompleteDraggable(item, index));
  }

  Widget displayDraggableItem() {
    List<int> imageIndex = Iterable<int>.generate(items.length).toList();
    return AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _transAnimation.value),
            child: child,
          );
        },
        child: Container(
            child: Stack(
                children: imageIndex.map((index) {
          ItemModel item = items[index];
          return item.type == 1
              ? displayFirstDraggableItem(item, index)
              : Container();
        }).toList())));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: data == null
          ? Container()
          : Container(
              child: Stack(
                children: [
                  displayBackground(),
                  // displayNormalItem(),
                  displayTargetItem(),
                  displayDraggableItem(),
                  BasicItem(),
                ],
              ),
            ),
    );
  }
}
