import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scratcher/scratcher.dart';
import 'package:svg_path_parser/svg_path_parser.dart';
import 'package:web_test/config/id_config.dart';
import 'package:web_test/model/item_model.dart';
import 'package:web_test/model/parent_game_model.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/basic_item.dart';
import 'package:web_test/widgets/character_item.dart';
import 'package:web_test/widgets/scale_animation.dart';
import 'package:web_test/widgets/tutorial_widget.dart';

class DrawAlphabet extends StatefulWidget {
  _DrawAlphabetState createState() => _DrawAlphabetState();
}

class _DrawAlphabetState extends State<DrawAlphabet>
    with TickerProviderStateMixin {
  List<Path> alphabetPath = [];
  List<List<Map>> _alphabetPoint = [];
  String _focusingItem = '';
  String currentColor = '#000000';

  // bool isCorrect = false;
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
  ParentGameModel allGameData;
  String assetFolder;
  ScreenModel screenModel;
  bool scaleNumber = true;
  int stepIndex;
  double screenHeight;
  double screenWidth;
  double ratio;
  Timer timer;
  bool isDisplayTutorialWidget = false;
  List<ItemModel> drawTutorial = [];

  void loadAlphabetData() {
    stepIndex = screenModel.currentStep;
    allGameData = screenModel.currentGame;
    for (int idx = 0;
        idx < allGameData.gameData[stepIndex].items.length;
        idx++) {
      alphabetData.add(allGameData.gameData[stepIndex].items[idx].copy());
    }
    double objectHeight = 0;
    assetFolder = allGameData.gameAssets;

    for (int index = 0; index < alphabetData.length; index++) {
      print(alphabetData[index].type);
      if (alphabetData[index].type == 1) {
        setState(() {
          _alphabetPoint.add([]);
          alphabetPath.add(parseSvgPath(alphabetData[index].path));
          imageLink.add(screenModel.localPath +
              allGameData.gameAssets +
              alphabetData[index].image);
          imagePosition.add(alphabetData[index].position);
          startPosition.add(alphabetData[index].startPosition);
          endPosition.add(alphabetData[index].endPosition);
        });
      } else if (alphabetData[index].type == 0) {
        drawTutorial.add(alphabetData[index]);
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
    bonusHeight = (screenHeight - 284 * ratio) / 2 - 47 * ratio;
    editPath();
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
    _initializeTimer();
  }

  Path scalePath(Path path) {
    final Matrix4 matrix4 = Matrix4.identity();
    matrix4.scale(ratio, ratio);
    return path.transform(matrix4.storage);
  }

  void editPath() {
    for (int idx = 0; idx < alphabetPath.length; idx++) {
      alphabetPath[idx] = scalePath(alphabetPath[idx]);
    }
  }

  removePoint() {
    if (!(_alphabetPoint[currentIndex].length == 0)) {
      deleteTimer = Timer.periodic(Duration(milliseconds: 10), (timer) {
        if (_alphabetPoint[currentIndex].length == 0) {
          deleteTimer.cancel();
          return;
        }
        _alphabetPoint[currentIndex]
            .removeAt(_alphabetPoint[currentIndex].length - 1);
        setState(() {});
      });
    }
  }

  addPoints(String action, Offset position) {
    print(position);
    if (!alphabetPath[currentIndex].contains(Offset(
        position.dx - imagePosition[currentIndex].dx * ratio,
        position.dy - imagePosition[currentIndex].dy * ratio - bonusHeight))) {
      print('Step 1');
      // removePoint();
      setState(() {
        _focusingItem = '';
        // _alphabetPoint=[];
      });
    }
    if (alphabetPath[currentIndex].contains(Offset(
            position.dx - imagePosition[currentIndex].dx * ratio,
            position.dy -
                imagePosition[currentIndex].dy * ratio -
                bonusHeight)) &&
        ((_focusingItem == '' && action == 'start') ||
            _focusingItem == 'alphabet')) {
      print('Step 2');
      // if (action != 'start' &&
      //     !alphabetPath[currentIndex].contains(Offset(
      //         (position.dx -
      //                 imagePosition[currentIndex].dx*ratio +
      //                 previousPoint.dx*ratio) /
      //             2,
      //         (position.dy -
      //                 imagePosition[currentIndex].dy*ratio -
      //                 bonusHeight +
      //                 previousPoint.dy*ratio) /
      //             2))) {
      //   print('Step 20');
      //   removePoint();
      //   setState(() {
      //     isColoringFromStart = false;
      //   });
      //   return;
      // }
      print('Step 3');
      setState(() {
        _alphabetPoint[currentIndex].add({
          'offset': Offset(
              position.dx - imagePosition[currentIndex].dx * ratio,
              position.dy -
                  imagePosition[currentIndex].dy * ratio -
                  bonusHeight),
          'color': Colors.red
        });
        previousPoint = Offset(
            position.dx - imagePosition[currentIndex].dx * ratio,
            position.dy - imagePosition[currentIndex].dy * ratio - bonusHeight);
      });
      if (action == 'start') {
        setState(() {
          isColoringFromStart = true;
          _focusingItem = 'alphabet';
        });
      }
    }
  }

  Widget displayTutorialWidget() {
    Offset startPositionPoint = startPosition[currentIndex];
    Offset endPositionPoint = endPosition[currentIndex];
    int groupId;

    return isDisplayTutorialWidget
        ? TutorialWidget(
            startPosition: startPositionPoint,
            endPosition: endPositionPoint,
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

  Widget displayDrawTutorial() {
    if(currentIndex<drawTutorial.length){
      ItemModel item = drawTutorial[currentIndex];
      print(item.image);
      return Positioned(
          top: item.position.dy * ratio,
          left: item.position.dx * ratio,
          child: Container(
            height: item.height * ratio,
            width: item.width * ratio,
            child: Image.asset(item.image),
          ));
    }else{
      return Container();
    }

  }

  Widget displayItem() {
    return Stack(
      children: [
        ScaleAnimation(
            beginValue: 0.0,
            endValue: 1.0,
            time: 1500,
            isScale: scaleNumber,
            curve: Curves.easeOutBack,
            child: Stack(
              children: [displayAlphabet(), displayDrawTutorial()],
            )),
        BasicItem(),
        // displayTutorialWidget()
      ],
    );
  }

  Widget displayAlphabet() {
    List<int> indexGenerate =
        Iterable<int>.generate(alphabetPath.length).toList();
    indexGenerate.sort((a, b) => b.compareTo(a));
    return Stack(
      children: indexGenerate.map((index) {
        return Positioned(
          left: imagePosition[index].dx * ratio,
          top: imagePosition[index].dy * ratio + bonusHeight,
          child: CharacterItem(
              imageLink[index],
              alphabetData[index].width * ratio,
              alphabetData[index].height * ratio,
              Colors.red,
              alphabetPath[index],
              _alphabetPoint[index],
              alphabetData[index].status == 1,
              ratio),
        );
      }).toList(),
    );
  }

  void onPanStartAction(Offset localPosition) {
    // print(localPosition);
    // print(startPosition[currentIndex]);

    if (currentColor != '' &&
        localPosition.dx <
            startPosition[currentIndex].dx * ratio + 50 * ratio &&
        localPosition.dx > startPosition[currentIndex].dx * ratio &&
        localPosition.dy >
            startPosition[currentIndex].dy * ratio + bonusHeight &&
        localPosition.dy <
            startPosition[currentIndex].dy * ratio + bonusHeight + 50 * ratio) {
      addPoints('start', localPosition);
    }
  }

  void onPanUpdateAction(Offset localPosition) {
    if (currentColor != '') {
      addPoints('update', localPosition);
      // print(localPosition);
      if (localPosition.dx <
              endPosition[currentIndex].dx * ratio + 70 * ratio &&
          localPosition.dx > endPosition[currentIndex].dx * ratio &&
          localPosition.dy <
              endPosition[currentIndex].dy * ratio + bonusHeight + 60 * ratio &&
          localPosition.dy >
              endPosition[currentIndex].dy * ratio + bonusHeight &&
          isColoringFromStart &&
          _alphabetPoint[currentIndex].length > 2) {
        setState(() {
          alphabetData[currentIndex].status = 1;
        });
      }
    }
  }

  void onPanEndAction() {
    if (currentColor != '') {
      if (alphabetData[currentIndex].status == 0) {
        removePoint();
        setState(() {
          isColoringFromStart = false;
        });
      } else {
        screenModel.playGameItemSound(LINE_CORRECT);
        if (currentIndex == alphabetPath.length - 1) {
          setState(() {
            scaleNumber = false;
          });
          screenModel.playGameItemSound(CORRECT);
          Timer(Duration(milliseconds: 1500), () {
            screenModel.nextStep();
          });
        }

        setState(() {
          currentIndex = currentIndex < alphabetData.length - 1
              ? currentIndex + 1
              : currentIndex;
          _focusingItem = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerDown: onPointerTap,
        onPointerMove: onPointerTap,
        onPointerUp: onPointerTap,
        child: Scaffold(
            body: alphabetData.length == 0
                ? Container()
                : Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: FileImage(File(screenModel.localPath +
                                assetFolder +
                                allGameData.gameData[stepIndex].background)),
                            fit: BoxFit.fill)),
                    child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onPanStart: (details) {
                          onPanStartAction(details.localPosition);
                        },
                        onPanUpdate: (details) {
                          onPanUpdateAction(details.localPosition);
                        },
                        onPanEnd: (details) {
                          onPanEndAction();
                        },
                        child: displayItem()),
                  )));
  }
}
