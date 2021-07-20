import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_test/model/item_model.dart';
import 'package:web_test/model/parent_game_model.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/animated_matched_target.dart';
import 'package:web_test/widgets/basic_item.dart';

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

  void loadAlphabetData() {
    stepIndex = screenModel.currentStep;
    allGameData = screenModel.currentGame;
    for (int idx = 0;
        idx < allGameData.gameData[stepIndex].items.length;
        idx++) {
      imageData.add(allGameData.gameData[stepIndex].items[idx].copy());
    }
    double objectHeight = 0;
    // assetFolder = screenModel.localPath+allGameData.gameAssets;
    assetFolder =
        allGameData.gameAssets + allGameData.gameData[stepIndex].stepAssets;
    bonusHeight = (375 - objectHeight) / 2;
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
    super.initState();
  }

  @override
  void didChangeDependencies() {
    screenWidth = screenModel.getScreenWidth();
    screenHeight = screenModel.getScreenHeight();
    ratio = screenModel.getRatio();
    super.didChangeDependencies();
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
                top: item.position.dy * ratio,
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
    return Stack(
      children: imageData.map((item) {
        return item.type == 3
            ? Positioned(
                top: item.position.dy * ratio,
                left: item.position.dx * ratio,
                child: Opacity(
                    opacity: count == sourceModel.length ? 1.0 : 0.0,
                    child: Container(
                        height: item.height * ratio,
                        width: item.width * ratio,
                        child: Image.file(
                          File(assetFolder + item.image),
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
            top: item.position.dy * ratio,
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
                screenModel.startPositionId = item.id;
                screenModel.startPosition =
                    Offset(item.position.dx * ratio, item.position.dy * ratio);
              },
              childWhenDragging: Container(),
              onDragEnd: (details) {
                bringToFront(item);
              },
              onDraggableCanceled: (velocity, offset) {
                screenModel.endPositionId = -1;
                screenModel.endPosition = offset;
                screenModel.logDragEvent(false);
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
            top: item.position.dy * ratio,
            left: item.position.dx * ratio,
            child: DragTarget<int>(
              builder: (context, candidateData, rejectedData) {
                return item.status == 0
                    ? Container(
                        height: item.height * ratio,
                        width: item.width * ratio,
                      )
                    : AnimatedMatchedTarget(
                        child: Container(
                            height: item.height*ratio,
                            width: item.width*ratio,
                            child: Image.file(
                              File(assetFolder + item.image),
                              fit: BoxFit.contain,
                            )));
              },
              onWillAccept: (data) {
                return data == item.groupId;
              },
              onAccept: (data) {
                screenModel.endPositionId = item.id;
                screenModel.endPosition = Offset(item.position.dx * ratio, item.position.dy * ratio);
                screenModel.logDragEvent(true);
                setCompletedStatus(item);
                if (count == sourceModel.length - 1) {
                  Timer(Duration(milliseconds: 2000), () {
                    setState(() {
                      count++;
                    });
                  });
                  Timer(Duration(milliseconds: 2500), () {
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
              )),
    );
  }
}
