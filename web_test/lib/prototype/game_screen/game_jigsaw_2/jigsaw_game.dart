import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:web_test/model/item_model.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/animated_matched_target.dart';
import 'package:web_test/widgets/animation_draggable_tap.dart';
import 'package:web_test/widgets/basic_item.dart';
import 'package:web_test/widgets/scale_animation.dart';

class JigsawGame extends StatefulWidget {
  _JigsawGameState createState() => _JigsawGameState();
}

class _JigsawGameState extends State<JigsawGame> {
  List<ItemModel> imageData = [];
  List data = [];
  double bonusHeight = 0;
  double ratio = 1;
  bool isWrongTarget = false;
  String assetFolder;
  var allGameData;
  List<ItemModel> sourceModel = [];
  List<ItemModel> targetModel = [];
  int count = 0;
  ScreenModel screenModel;
  int stepIndex;

  void loadAlphabetData() {
    stepIndex=screenModel.currentStep;
    allGameData=screenModel.currentGame;
    data = allGameData['gameData'][stepIndex]['items'];
    double objectHeight = allGameData['gameData'][stepIndex]['height'];
    assetFolder = screenModel.localPath+allGameData['gameAssets'];
    bonusHeight = (375 - objectHeight) / 2;
    imageData = data
        .map((draggableInfo) => new ItemModel.fromJson(draggableInfo))
        .toList();
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
    super.initState();
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
    loadAlphabetData();
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
                top: item.position.dy,
                left: item.position.dx,
                child: Container(
                    height: item.height,
                    width: item.width,
                    child: Image.asset(
                      assetFolder + item.image,
                      fit: BoxFit.contain,
                    )))
            : Container();
      }).toList(),
    );
  }

  Widget displayCompletedImage() {
    return Stack(
      children: imageData.map((item) {
        return item.type == 3
            ? Positioned(
                top: item.position.dy,
                left: item.position.dx,
                child: Opacity(
                    opacity: count == sourceModel.length ? 1.0 : 0.0,
                    child: Container(
                        height: item.height,
                        width: item.width,
                        child: Image.asset(
                          assetFolder + item.image,
                          fit: BoxFit.contain,
                        ))))
            : Container();
      }).toList(),
    );
  }

  Widget displayDraggable() {
    return Stack(
      children: sourceModel.map((item) {
        return Positioned(
            top: item.position.dy,
            left: item.position.dx,
            child: Draggable(
              data: item.groupId,
              child: item.status == 0
                  ? Container(
                      height: item.height * 0.9,
                      width: item.width * 0.9,
                      child: Image.asset(
                        assetFolder + item.image,
                        fit: BoxFit.contain,
                      ))
                  : Container(),
              feedback: Container(
                height: item.height,
                width: item.width,
                child: Image.asset(
                  assetFolder + item.image,
                  fit: BoxFit.contain,
                ),
              ),
              childWhenDragging: Container(),
              onDragEnd: (details) {
                bringToFront(item);
              },
              onDraggableCanceled: (velocity, offset) {
                item.position = offset;
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
            top: item.position.dy,
            left: item.position.dx,
            child: DragTarget<int>(
              builder: (context, candidateData, rejectedData) {
                return item.status == 0
                    ? Container(
                        height: item.height,
                        width: item.width,
                      )
                    : AnimatedMatchedTarget(
                        child: Container(
                            height: item.height,
                            width: item.width,
                            child: Image.asset(
                              assetFolder + item.image,
                              fit: BoxFit.contain,
                            )));
              },
              onWillAccept: (data) {
                return data == item.groupId;
              },
              onAccept: (data) {
                setCompletedStatus(item);
                if (count == sourceModel.length - 1) {
                  Timer(Duration(milliseconds: 2000), () {
                    setState(() {
                      count++;
                    });
                  });
                  Timer(Duration(milliseconds: 2500),(){
                    screenModel.nextStep();
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

  List<Widget> displayScreen() {
    List<Widget> widgets = [];
    widgets.add(displayCompletedImage());
    if (count == sourceModel.length) {
    } else {
      widgets.add(displayShadow());
      widgets.add(displayTarget());
      widgets.add(displayDraggable());
    }
    widgets.add(BasicItem());
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: data.length == 0
          ? Container()
          : Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(assetFolder +
                          allGameData['gameData'][stepIndex]['background']),
                      fit: BoxFit.fill)),
              child: Stack(
                children: displayScreen(),
              )),
    );
  }
}
