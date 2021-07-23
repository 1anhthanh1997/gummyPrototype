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
import 'package:web_test/widgets/pair_scale_animation.dart';
import 'package:web_test/widgets/scale_animation.dart';

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
  bool isDisplayTutorialWidget=false;

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
        pairCount++;
      }
    }
    setState(() {
      pairCount = pairCount ~/ 2;
    });
    print(pairCount);
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

  void resetScaleArray() {
    for (int idx = 0; idx < isScale.length; idx++) {
      isScale[idx] = 0;
    }
  }

  Widget displayContent() {
    List<int> targetIndex = Iterable<int>.generate(itemData.length).toList();
    return Stack(
      children: targetIndex.map((index) {
        print(index);
        ItemModel item = itemData[index];
        return item.status == 0
            ? Positioned(
                left: item.position.dx * ratio,
                top: item.position.dy * ratio  +
                    (index % 2 == 0 ? firstBonusHeight : secondBonusHeight),
                child: PairScaleAnimation(
                  itemId: item.id,
                  isScale: isScale[index] == 1,
                  onTab: () {
                    if (firstItem != item.id) {
                      if (chosenIndex != -1) {
                        if (itemData[chosenIndex].groupId == item.groupId &&
                            index != chosenIndex) {
                          setState(() {
                            isScale[index] = 1;
                          });
                          Timer(Duration(milliseconds: 330), () {
                            print(chosenIndex);
                            print(index);
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
                              });
                            }
                          });
                        } else {
                          setState(() {
                            chosenIndex = -1;
                            firstItem = -1;
                            isScale[index] = 0;
                          });
                          resetScaleArray();
                        }
                      } else {
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
                    // {
                    //   if (itemData[chosenIndex].groupId == item.groupId &&
                    //       index != chosenIndex) {
                    //     Timer(Duration(milliseconds: 330), () {
                    //       setState(() {
                    //         count++;
                    //         itemData[chosenIndex].status = 1;
                    //         itemData[index].status = 1;
                    //         chosenIndex = -1;
                    //       });
                    //       if(count==pairCount){
                    //         Timer(Duration(milliseconds: 1500),(){
                    //           screenModel.nextStep();
                    //         });
                    //       }
                    //     });
                    //   } else {
                    //     resetScaleArray();
                    //   }
                    // }
                  },
                  child: Container(
                    height: item.height * ratio,
                    width: item.width * ratio,
                    child: SvgPicture.file(
                      File(assetFolder + item.image),
                      fit: BoxFit.contain,
                    ),
                  ),
                ))
            : Positioned(
                left: item.position.dx * ratio - item.width * 0.1 * ratio,
                top: item.position.dy * ratio -
                    item.height * 0.2 * ratio +
                    (index % 2 == 0 ? firstBonusHeight : secondBonusHeight),
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

  Widget displayNormalItem() {
    return Stack(
      children: itemData.map((item) {
        return Positioned(
            left: item.position.dx,
            top: item.position.dy,
            child: item.type == 2
                ? Container(
                    height: item.height,
                    width: item.width,
                    child: SvgPicture.file(
                      File(assetFolder + item.image),
                      fit: BoxFit.contain,
                    ),
                  )
                : Container());
      }).toList(),
    );
  }

  Widget displayTutorialWidget() {
    // Offset startPosition = Offset(0, 0);
    // Offset endPosition = Offset(0, 0);
    // int groupId;
    // for (int index = 0; index < sourceModel.length; index++) {
    //   ItemModel item = sourceModel[index];
    //   if (item.status == 0) {
    //     startPosition = Offset(
    //         item.position.dx * ratio + item.width / 2 * ratio,
    //         item.position.dy * ratio + item.height / 2 * ratio + firstBonusHeight);
    //     groupId = item.groupId;
    //     break;
    //   }
    // }
    // for (int index = 0; index < targetModel.length; index++) {
    //   ItemModel item = targetModel[index];
    //   if (item.status == 0 && item.groupId == groupId) {
    //     endPosition = Offset(item.position.dx * ratio + item.width / 2 * ratio,
    //         screenHeight * 3 / 4 );
    //     break;
    //   }
    // }
    // print(isDisplayTutorialWidget);
    //
    // return isDisplayTutorialWidget
    //     ? TutorialWidget(
    //   startPosition: startPosition,
    //   endPosition: endPosition,
    //   onCompleted: () {
    //     Timer(Duration(milliseconds: 200), () {
    //       setState(() {
    //         isDisplayTutorialWidget = false;
    //       });
    //     });
    //   },
    // )
    //     : Container();
  }

  List<Widget> displayScreen() {
    List<Widget> widgets = [];
    widgets.add(displayContent());
    widgets.add(BasicItem());
    // widgets.add(displayTutorialWidget());
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerDown: onPointerTap,
        onPointerMove: onPointerTap,
        onPointerUp: onPointerTap,
        child:Scaffold(
      body: itemData.length == 0
          ? Container()
          : Container(
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
