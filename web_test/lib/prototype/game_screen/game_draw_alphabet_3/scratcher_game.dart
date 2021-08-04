import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:scratcher/scratcher.dart';
import 'package:web_test/config/id_config.dart';
import 'package:web_test/model/item_model.dart';
import 'package:web_test/model/parent_game_model.dart';
import 'package:web_test/prototype/general_screen/tap_tutorial_widget.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/basic_item.dart';
import 'package:web_test/widgets/scale_animation.dart';
import 'package:web_test/widgets/scratcher_appear.dart';
import 'package:web_test/widgets/tutorial/scratcher_tutorial.dart';

class ScratcherGame extends StatefulWidget {
  _ScratcherGameState createState() => _ScratcherGameState();
}

class _ScratcherGameState extends State<ScratcherGame>
    with TickerProviderStateMixin {
  List<Path> alphabetPath = [];
  String currentColor = '#000000';
  bool isCorrect = false;
  Offset previousPoint = Offset(0, 0);
  bool isColoringFromStart = false;
  Timer deleteTimer;
  Timer secondDeleteTimer;
  Timer thirdDeleteTimer;
  List<ItemModel> data;
  List<ItemModel> alphabetData = [];
  List<String> imageLink = [];
  List<Offset> imagePosition = [];
  List<Offset> startPosition = [];
  List<Offset> endPosition = [];
  int currentIndex = 0;
  double bonusHeight = 0;
  List<ItemModel> imageData = [];
  List<ItemModel> sourceImage = [];
  List<ItemModel> sourceModel = [];
  ParentGameModel allGameData;
  String assetFolder;
  List<bool> isCompleted = [];
  List<Offset> positionListTmp = [];
  int count = 0;
  ScreenModel screenModel;
  int stepIndex;
  double screenWidth;
  double screenHeight;
  double ratio;
  bool isAppear = true;
  Timer timer;
  bool isDisplayTutorialWidget = false;

  void loadAlphabetData() {
    stepIndex = screenModel.currentStep;
    allGameData = screenModel.currentGame;
    for (int idx = 0;
        idx < allGameData.gameData[stepIndex].items.length;
        idx++) {
      imageData.add(allGameData.gameData[stepIndex].items[idx].copy());
    }
    assetFolder = screenModel.localPath + allGameData.gameAssets;
    imageData.map((item) {
      // print(item.type);
      if (item.type == 1) {
        sourceImage.add(item);
      }
    }).toList();
    List<Offset> position = [
      Offset(249, 37),
      Offset(422, 37),
      Offset(249, 201),
      Offset(422, 201)
    ];
    for (int idx = 0; idx < 4; idx++) {
      Random random = Random();
      int sourceIndex = random.nextInt(sourceImage.length);
      ItemModel item = sourceImage[sourceIndex];
      item.position = position[idx];
      sourceModel.add(item);
      sourceImage.removeAt(sourceIndex);
    }
    for (int idx = 0; idx < sourceModel.length; idx++) {
      isCompleted.add(false);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
    loadAlphabetData();
    _initializeTimer();
  }

  @override
  void didChangeDependencies() {
    screenWidth = screenModel.getScreenWidth();
    screenHeight = screenModel.getScreenHeight();
    ratio = screenModel.getRatio();
    bonusHeight = (screenHeight - 319 * ratio) / 2 - 28 * ratio;
    Timer(Duration(milliseconds: 500), () {
      setState(() {
        isAppear = false;
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
    if (timer == null) {
      return;
    }
    setState(() {
      isDisplayTutorialWidget = false;
    });
    timer.cancel();
    _initializeTimer();
  }

  Widget displayScratcherItem(ItemModel item, int index) {
    return isCompleted[index]
        ? Positioned(
            top: item.position.dy * ratio + bonusHeight,
            left: item.position.dx * ratio,
            child: Container(
              height: 138 * ratio,
              width: 138 * ratio,
              alignment: Alignment.center,
              child: Container(
                height: item.height * ratio,
                width: item.width * ratio,
                child: Image.file(File(assetFolder + item.image)),
              ),
            ),
          )
        : AnimatedPositioned(
            top: item.position.dy * ratio + bonusHeight,
            left: item.position.dx * ratio,
            duration: Duration(milliseconds: 500),
            child: Scratcher(
              brushSize: 30 * ratio,
              threshold: 60,
              color: HexColor('#00FFFFFF'),
              image: Image.asset(
                'assets/images/game_draw_alphabet_3/draw_A/scratcher.png',
                fit: BoxFit.fill,
              ),
              onChange: (value) {
                screenModel.playGameItemSound(SWEEPING_2);
                print("Scratch progress: $value%");
              },
              onThreshold: () {
                setState(() {
                  isCompleted[index] = true;
                  count++;
                });
                if (count == isCompleted.length) {
                  screenModel.playGameItemSound(CORRECT);
                  Timer(Duration(milliseconds: 1000), () {
                    screenModel.nextStep();
                  });
                }
              },
              child: Container(
                height: 138 * ratio,
                width: 138 * ratio,
                alignment: Alignment.center,
                child: Container(
                  height: item.height * ratio,
                  width: item.width * ratio,
                  child: Image.file(File(assetFolder + item.image)),
                ),
              ),
            ));
  }

  Widget scratcher() {
    List<int> imageIndex = Iterable<int>.generate(sourceModel.length).toList();
    return ScratcherAppear(
      beginValue: 0.0,
      endValue: 1.0,
      time: 500,
      delayTime: 600,
      curve: Curves.easeOutBack,
      isScale: isAppear,
      isReverse: false,
      child: Stack(
        children: imageIndex.map((index) {
          return displayScratcherItem(sourceModel[index], index);
        }).toList(),
      ),
    );
  }

  Widget scratcherBackground() {
    return Positioned(
        top: screenHeight / 2 - 338 / 2 * ratio,
        left: screenWidth / 2 - 597 / 2 * ratio,
        child: ScratcherAppear(
            beginValue: 0.0,
            endValue: 1.0,
            time: 500,
            delayTime: 600,
            curve: Curves.easeOutBack,
            isScale: isAppear,
            isReverse: false,
            child: Container(
              height: 338 * ratio,
              width: 597 * ratio,
              child: Image.asset(
                  'assets/images/game_draw_alphabet_3/draw_A/scratcher_image.png'),
            )));
  }

  Widget displayTutorialWidget() {
    Offset startPosition = Offset(0, 0);
    Offset endPosition = Offset(0, 0);
    for (int idx = 0; idx < sourceModel.length; idx++) {
      ItemModel item = sourceModel[idx];
      startPosition = Offset(item.position.dx * ratio + 49 * ratio,
          item.position.dy * ratio + 49 * ratio + bonusHeight);
      endPosition = Offset(item.position.dx * ratio + 89 * ratio,
          item.position.dy * ratio + 89 * ratio + bonusHeight);
    }

    return isDisplayTutorialWidget
        ? ScratcherTutorial(
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

  Widget displayScreen() {
    return Stack(
      children: [scratcherBackground(), scratcher(), BasicItem(),displayTutorialWidget()],
    );
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
                child: displayScreen())));
  }
}
