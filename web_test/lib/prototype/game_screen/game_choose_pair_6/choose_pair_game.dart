import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:web_test/config/id_config.dart';
import 'package:web_test/model/item_model.dart';
import 'package:web_test/model/parent_game_model.dart';
import 'package:web_test/prototype/general_screen/tap_tutorial_widget.dart';
import 'package:web_test/prototype/general_screen/winning_screen.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/appear_animation.dart';
import 'package:web_test/widgets/basic_item.dart';
import 'package:web_test/widgets/correct_animation.dart';
import 'package:web_test/widgets/pair_scale_animation.dart';
import 'package:web_test/widgets/scale_animation.dart';
import 'package:web_test/widgets/skip_screen.dart';

class ChoosePairGame extends StatefulWidget {
  _ChoosePairGameState createState() => _ChoosePairGameState();
}

class _ChoosePairGameState extends State<ChoosePairGame> {
  List<ItemModel> itemData = [];
  List<int> draggableKey = [];
  List<int> targetKey = [];
  String assetFolder = '';
  int chosenIndex = -1;
  ParentGameModel allGameData;
  List<int> isScale = [];
  List<ItemModel> sourceModel = [];
  ScreenModel screenModel;
  int count = 0;
  int pairCount = 0;
  int stepIndex;
  int firstItem = -1;
  double screenWidth;
  double screenHeight;
  double ratio;
  double firstBonusHeight;
  double secondBonusHeight;
  Timer timer;
  bool isDisplayTutorialWidget = false;
  List<int>delayIndex=[];
  bool isDisplaySkipScreen=false;

  void loadGameData() {
    stepIndex = screenModel.currentStep;
    allGameData = screenModel.currentGame;
    for (int idx = 0;
        idx < allGameData.gameData[stepIndex].items.length;
        idx++) {
      itemData.add(allGameData.gameData[stepIndex].items[idx].copy());
    }
    assetFolder = screenModel.localPath + allGameData.gameAssets;
    print(assetFolder);
    for (int idx = 0; idx < itemData.length; idx++) {
      isScale.add(0);
      if (itemData[idx].type == 1) {
        sourceModel.add(itemData[idx]);
        pairCount++;
      }
    }
    List<double> horizontalPosition = [160, 320, 457, 594];

    for (int index = 0; index < 4; index++) {
      Random random=Random();
      double randomValue=horizontalPosition[random.nextInt(horizontalPosition.length)];
      ItemModel item = sourceModel[index];
      sourceModel[index].position =
          Offset(randomValue, item.position.dy);
      horizontalPosition.remove(randomValue);
    }

    horizontalPosition = [160, 320, 457, 594];
    for (int index = 4; index < 8; index++) {
      Random random=Random();
      double randomValue=horizontalPosition[random.nextInt(horizontalPosition.length)];
      ItemModel item = sourceModel[index];
      sourceModel[index].position =
          Offset(randomValue, item.position.dy);
      horizontalPosition.remove(randomValue);
    }

    horizontalPosition = [160, 320, 457, 594];
    for(int index=0;index<sourceModel.length;index++){
      for(int idx=0;idx<horizontalPosition.length;idx++){
        if(sourceModel[index].position.dx==horizontalPosition[idx]){
          delayIndex.add((index~/4)*4+idx);
          break;
        }
      }
    }

    // for (int index = 0; index < 8; index++) {
    //  print(sourceModel[index].position);
    // }
    setState(() {
      pairCount = pairCount ~/ 2;
    });
  }

  @override
  void initState() {
    print('InitState');
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
    loadGameData();
    _initializeTimer();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    screenWidth = screenModel.getScreenWidth();
    screenHeight = screenModel.getScreenHeight();
    ratio = screenModel.getRatio();
    firstBonusHeight = screenHeight * 0.41 - 90 * ratio - 62 * ratio;
    secondBonusHeight = screenHeight * 0.77 - 90 * ratio - 198 * ratio;
    isDisplaySkipScreen=screenModel.isDisplaySkipScreen;
   Timer(Duration(milliseconds: 800),(){
      setState(() {
        isDisplaySkipScreen=false;
      });
    });
    super.didChangeDependencies();
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

  void resetScaleArray() {
    for (int idx = 0; idx < isScale.length; idx++) {
      isScale[idx] = 0;
    }
  }

  Widget displayContent() {
    List<int> targetIndex = Iterable<int>.generate(sourceModel.length).toList();
    return Stack(
      children: targetIndex.map((index) {
        ItemModel item = sourceModel[index];
        return item.status == 0
            ? Positioned(
                left: item.position.dx * ratio,
                top: item.position.dy * ratio +
                    (index < 4 ? firstBonusHeight : secondBonusHeight),
                child: AppearAnimation(
                  delay: delayIndex[index] * 150,
                  child: PairScaleAnimation(
                    itemId: item.id,
                    isScale: isScale[index] == 1,
                    onTab: () {
                      if (firstItem != item.id) {
                        if (chosenIndex != -1) {
                          if (itemData[chosenIndex].groupId == item.groupId &&
                              index != chosenIndex) {
                            screenModel.playGameItemSound(PICK_COLOR);
                            setState(() {
                              isScale[index] = 1;
                            });
                            Timer(Duration(milliseconds: 220), () {
                              screenModel.playGameItemSound(CORRECT_2);
                              // print(chosenIndex);
                              // print(index);
                              setState(() {
                                count++;
                                itemData[chosenIndex].status = 1;
                                itemData[index].status = 1;
                                chosenIndex = -1;
                                firstItem = -1;
                              });
                              if (count == pairCount) {
                                Timer(Duration(milliseconds: 1500), () {
                                  screenModel.nextStep();
                                  if (screenModel.currentStep ==
                                      screenModel.currentGame.gameData.length -
                                          1) {
                                    if (timer != null) {
                                      timer.cancel();
                                    }
                                  }
                                });
                              }
                            });
                          } else {
                            screenModel.playGameItemSound(WRONG_COLOR);
                            setState(() {
                              chosenIndex = -1;
                              firstItem = -1;
                              isScale[index] = 0;
                            });
                            resetScaleArray();
                          }
                        } else {
                          screenModel.playGameItemSound(PICK_COLOR);
                          setState(() {
                            chosenIndex = index;
                            firstItem = item.id;
                            isScale[index] = 1;
                          });
                        }
                      } else {
                        print('Scale down');
                        setState(() {
                          chosenIndex = -1;
                          firstItem = -1;
                          isScale[index] = 0;
                        });
                      }
                    },
                    child: Container(
                      // color: Colors.red,
                      height: item.height * ratio,
                      width: item.width * ratio,
                      child: SvgPicture.file(
                        File(assetFolder + item.image),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ))
            : Positioned(
                left: item.position.dx * ratio - item.width * 0.1 * ratio,
                top: item.position.dy * ratio -
                    item.height * 0.2 * ratio +
                    (index < 4 ? firstBonusHeight : secondBonusHeight),
                child: CorrectAnimation(
                  isCorrect: item.status == 1,
                  child: Container(
                    height: item.height * 1.2 * ratio,
                    width: item.width * 1.2 * ratio,
                    child: SvgPicture.file(
                      File(assetFolder + item.image),
                      fit: BoxFit.contain,
                    ),
                  ),
                ));
      }).toList(),
    );
  }

  Widget displayTutorialWidget() {
    Offset position = Offset(0, 0);
    if (chosenIndex == -1) {
      for (int idx = 0; idx < itemData.length; idx++) {
        ItemModel item = itemData[idx];
        if (item.status == 0) {
          double dx = item.position.dx * ratio + item.width * ratio / 2;
          double dy = item.position.dy * ratio +
              (idx < 4 ? firstBonusHeight : secondBonusHeight) +
              item.height * ratio / 2;
          position = Offset(dx, dy);
          break;
        }
      }
    } else {
      int currentGroupId = itemData[chosenIndex].groupId;
      for (int idx = 0; idx < itemData.length; idx++) {
        ItemModel item = itemData[idx];
        if (item.groupId == currentGroupId && idx != chosenIndex) {
          double dx = item.position.dx * ratio + item.width * ratio / 2;
          double dy = item.position.dy * ratio +
              (idx < 4 ? firstBonusHeight : secondBonusHeight) +
              item.height * ratio / 2;
          position = Offset(dx, dy);
          break;
        }
      }
    }
    return isDisplayTutorialWidget
        ? Positioned(
            top: position.dy,
            left: position.dx,
            child: TabTutorialWidget(
              beginValue: 1.0,
              endValue: 0.7,
              time: 500,
              onCompleted: () {
                Timer(Duration(milliseconds: 400), () {
                  setState(() {
                    isDisplayTutorialWidget = false;
                  });
                });
              },
            ))
        : Container();
  }

  List<Widget> displayScreen() {
    List<Widget> widgets = [];
    widgets.add(displayContent());
    widgets.add(BasicItem());
    if(isDisplaySkipScreen){
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
            ),
          ),
        ));
  }
}
