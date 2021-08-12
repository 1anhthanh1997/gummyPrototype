import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:web_test/config/id_config.dart';
import 'package:web_test/model/item_model.dart';
import 'package:web_test/model/parent_game_model.dart';
import 'package:web_test/prototype/general_screen/tap_tutorial_widget.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/appear_animation.dart';
import 'package:web_test/widgets/basic_item.dart';
import 'package:web_test/widgets/bubble_animation.dart';
import 'package:web_test/widgets/bubble_scale.dart';
import 'package:web_test/widgets/opacity_animation.dart';
import 'package:web_test/widgets/particle.dart';
import 'package:web_test/widgets/skip_screen.dart';
import 'package:web_test/widgets/slide_animation.dart';

class GameMemoryNumber extends StatefulWidget {
  _GameMemoryNumberState createState() => _GameMemoryNumberState();
}

class _GameMemoryNumberState extends State<GameMemoryNumber> {
  List<ItemModel> itemData = [];
  List<int> draggableKey = [];
  List<int> targetKey = [];
  String assetFolder = '';
  ItemModel questionData;
  Offset questionPositionTmp = Offset(0, 0);
  List<Offset> answerPositionTmp = [];
  List<ItemModel> answerData = [];

  List<List<SquareParticle>> particles = [];
  bool isDisplayAnswer = false;
  ParentGameModel allGameData;
  ScreenModel screenModel;
  int count = 0;
  int answerCount = 0;

  double screenWidth;
  double screenHeight;
  double ratio;
  Timer timer;
  bool isDisplayTutorialWidget = false;
  bool isDisplaySkipScreen = false;
  List<String> colors = [
    '#00C55A',
    '#0094BF',
    '#F47B2A',
    '#FF400C',
    '#ECA919',
    '#C148EC',
    '#F42AA3',
    '#605DF2',
    '#DD6349'
  ];
  List<Offset> offsets = [
    Offset(86, 68),
    Offset(148, 179),
    Offset(206, 56),
    Offset(262, 177),
    Offset(362, 66),
    Offset(435, 159),
    Offset(512, 72),
    Offset(586, 157),
    Offset(664, 66)
  ];
  int answerDuration = 1000;
  List<bool> isScale = [];

  void loadGameData() {
    allGameData = screenModel.currentGame;
    int stepIndex = screenModel.currentStep;
    for (int idx = 0;
        idx < allGameData.gameData[stepIndex].items.length;
        idx++) {
      itemData.add(allGameData.gameData[stepIndex].items[idx].copy());
    }
    assetFolder = screenModel.localPath + allGameData.gameAssets;
    for (int index = 0; index < itemData.length; index++) {
      if (itemData[index].type == 0) {
        questionPositionTmp = itemData[index].position;
        itemData[index].position =
            Offset(screenWidth / 2, screenHeight + 125 * ratio);
        questionData = itemData[index];
        Random random = Random();
        questionData.groupId = random.nextInt(3);
      } else {
        Random random = Random();
        String chosenColor = colors[random.nextInt(colors.length)];
        Random positionRandom = Random();
        Offset chosenPosition = offsets[positionRandom.nextInt(offsets.length)];
        if (itemData[index].groupId != questionData.groupId) {
          int chosenGroupId = questionData.groupId;
          while (chosenGroupId == questionData.groupId) {
            Random idRandom = Random();
            chosenGroupId = idRandom.nextInt(9);
          }
          itemData[index].groupId = chosenGroupId;
          itemData[index].image = genImageLink(chosenGroupId);
        }

        answerPositionTmp.add(chosenPosition);
        itemData[index].position =
            Offset(screenWidth / 2, screenHeight + 125 * ratio);
        itemData[index].color = chosenColor;
        answerData.add(itemData[index]);
        isScale.add(false);
        particles.add([]);
        offsets.remove(chosenPosition);
      }
    }
    for (int index = 0; index < itemData.length; index++) {
      if (itemData[index].groupId == questionData.groupId &&
          itemData[index].type == 1) {
        setState(() {
          answerCount++;
        });
      }
    }
    print('Answer Count');
    print(answerCount);
  }

  String genImageLink(int groupId) {
    switch (groupId) {
      case 0:
        return 'one.svg';
      case 1:
        return 'two.svg';
      case 2:
        return 'three.svg';
      case 3:
        return 'four.svg';
      case 4:
        return 'five.svg';
      case 5:
        return 'six.svg';
      case 6:
        return 'seven.svg';
      case 7:
        return 'eight.svg';
      case 8:
        return 'nine.svg';
      default:
        return 'one.svg';
    }
  }

  void resetState() {
    isScale=[];
    itemData = [];
    questionPositionTmp = Offset(0, 0);
    answerPositionTmp = [];
    answerData = [];
    particles = [];
    isDisplayAnswer = false;
    count = 0;
    answerCount = 0;
    isDisplayTutorialWidget = false;
    isDisplaySkipScreen = false;
    colors = [
      '#00C55A',
      '#0094BF',
      '#F47B2A',
      '#FF400C',
      '#ECA919',
      '#C148EC',
      '#F42AA3',
      '#605DF2',
      '#DD6349'
    ];
    offsets = [
      Offset(86, 68),
      Offset(148, 179),
      Offset(206, 56),
      Offset(262, 177),
      Offset(362, 66),
      Offset(435, 159),
      Offset(512, 72),
      Offset(586, 157),
      Offset(664, 66)
    ];
    screenModel.playGameItemSound(COUNT_DOWN);
    Timer(Duration(milliseconds: 2000), () {
      Timer(Duration(milliseconds: 500), () {
        for (int index = 0; index < answerPositionTmp.length; index++) {
          answerData[index].position = answerPositionTmp[index];
        }
        setState(() {});
      });
      setState(() {
        isDisplayAnswer = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
    Timer(Duration(milliseconds: 4000), () {
      _initializeTimer();
    });
  }

  @override
  void didChangeDependencies() {
    screenWidth = screenModel.getScreenWidth();
    screenHeight = screenModel.getScreenHeight();
    ratio = screenModel.getRatio();
    loadGameData();
    print(questionPositionTmp);
    screenModel.playGameItemSound(COUNT_DOWN);
    Timer(Duration(milliseconds: 2000), () {
      Timer(Duration(milliseconds: 500), () {
        for (int index = 0; index < answerPositionTmp.length; index++) {
          answerData[index].position = answerPositionTmp[index];
        }
        setState(() {});
      });
      setState(() {
        isDisplayAnswer = true;
      });
    });
    isDisplaySkipScreen = screenModel.isDisplaySkipScreen;
    Timer(Duration(milliseconds: 1100), () {
      setState(() {
        isDisplaySkipScreen = false;
      });
      screenModel.isDisplaySkipScreen = false;
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

  String getAssetLink() {
    switch (questionData.groupId) {
      case 0:
        {
          return 'assets/images/game_memory_number_7/number/one.png';
        }
      case 1:
        {
          return 'assets/images/game_memory_number_7/number/two.png';
        }
      case 2:
        {
          return 'assets/images/game_memory_number_7/number/three.png';
        }
    }
  }

  Widget _square(int index) {
    ItemModel item = answerData[index];
    return Container(
      height: item.height * ratio,
      width: item.width * ratio,
      child: SvgPicture.file(
        File(assetFolder + item.image),
        color: HexColor(item.color),
        fit: BoxFit.contain,
      ),
    );
  }

  _hitSquare(Duration time, int index) {
    // _setSquareVisible(false);
    // Timer(Duration(milliseconds: 800),(){
    setState(() {
      count++;
      answerData[index].status = 1;
    });
    print(answerCount);
    print(count);
    if (count == answerCount) {
      screenModel.playGameItemSound(CORRECT);
      Timer(Duration(milliseconds: 1000), () {
        for (int index = 0; index < answerData.length; index++) {
          Timer(Duration(milliseconds: 100 * index), () {
            answerData[index].position =
                Offset(answerData[index].position.dx, -300 * ratio);
            setState(() {});
          });
        }
      });
      Timer(Duration(milliseconds: 3000), () {
        if (screenModel.currentStep ==
            screenModel.currentGame.gameData.length - 1) {
          if (timer != null) {
            timer.cancel();
          }
          screenModel.setContext(context);
          screenModel.nextStep();
        } else {
          screenModel.nextStep();
          resetState();
          loadGameData();
        }
      });
    }
    // });

    Iterable.generate(8).forEach((i) {
      List<String> balloonShardList = [
        BALLOON_SHARD_1,
        BALLOON_SHARD_2,
        BALLOON_SHARD_3,
        BALLOON_SHARD_4,
        BALLOON_SHARD_5,
        BALLOON_SHARD_6,
        BALLOON_SHARD_7,
        BALLOON_SHARD_8,
      ];
      Random random = Random();
      String balloonShardUrl =
          balloonShardList[random.nextInt(balloonShardList.length)];
      particles[index]
          .add(SquareParticle(time, ratio, 197, 87, balloonShardUrl,[],400,150,150));
    });
  }

  Widget displayQuestion() {
    screenModel.playGameItemSound(START);
    return Positioned(
        top: screenHeight / 2 - 197 / 2 * ratio,
        left: screenWidth / 2 - 87 / 2 * ratio,
        child: AppearAnimation(
          reverseTime: 2000,
          child: Container(
            height: 197 * ratio,
            width: 87 * ratio,
            child: Image.asset(getAssetLink()),
          ),
        ));
  }

  Widget _buildParticle(int index) {
    ItemModel item = answerData[index];
    return Rendering(
      // onTick: (time) => _manageParticleLife(time),
      builder: (context, time) {
        return Stack(
          overflow: Overflow.visible,
          children: [
            item.status == 0
                ? GestureDetector(
                    onTapDown: (details) {
                      List<String> bubbleSound = [BALLOON_POP_A, BALLOON_POP_B];
                      Random random = Random();
                      String chosenSound =
                          bubbleSound[random.nextInt(bubbleSound.length)];
                      screenModel.playGameItemSound(chosenSound);
                      screenModel.logTapEvent(item.id, details.globalPosition);
                    },
                    onTap: () {
                      setState(() {
                        isScale[index] = true;
                      });
                      Timer(Duration(milliseconds: 100), () {
                        _hitSquare(time, index);
                      });
                    },
                    child: _square(index))
                : Container(),
            ...particles[index]
                .map((it) => it.buildWidget(time, HexColor(item.color),false))
          ],
        );
      },
    );
  }

  Widget displayAnswer() {
    List<int> answerIndex = Iterable<int>.generate(answerData.length).toList();
    return Stack(
      children: answerIndex.map((index) {
        ItemModel item = answerData[index];
        print(item.color);
        return item.type == 1 && item.groupId == questionData.groupId
            ? AnimatedPositioned(
                left: item.position.dx * ratio,
                top: item.position.dy * ratio,
                duration: Duration(milliseconds: answerDuration),
                curve: Curves.fastOutSlowIn,
                child: BubbleAnimation(
                  child:BubbleScale(
                    isScale: isScale[index],
                    beginValue: 1.0,
                    endValue: 1.1,
                    time: 100,
                    child:_buildParticle(index),
                  )
                ))
            : AnimatedPositioned(
                left: item.position.dx * ratio,
                top: item.position.dy * ratio,
                duration: Duration(milliseconds: answerDuration),
                curve: Curves.fastOutSlowIn,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      answerData[index].position = Offset(
                          item.position.dx, item.position.dy + 10 * ratio);
                      answerDuration = 150;
                    });
                    Timer(Duration(milliseconds: 150), () {
                      setState(() {
                        answerData[index].position = Offset(
                            item.position.dx, item.position.dy - 10 * ratio);
                      });
                    });
                    Timer(Duration(milliseconds: 300), () {
                      setState(() {
                        answerDuration = 1000;
                      });
                    });
                  },
                  child: BubbleAnimation(
                    child: Container(
                      height: 194 * ratio,
                      width: 60 * ratio,
                      child: SvgPicture.file(
                        File(assetFolder + item.image),
                        color: HexColor(item.color),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ));
      }).toList(),
    );
  }

  Widget displayHotAirBalloon() {
    return Positioned(
        top: 33 * ratio,
        left: 665 * ratio,
        child: SlideAnimation(
            beginValue: -1 * screenWidth - 88 * ratio,
            endValue: 250.0 * ratio,
            time: 40000,
            child: Opacity(
              opacity: 0.75,
              child: BubbleAnimation(
                child: Container(
                  height: 96 * ratio,
                  width: 71 * ratio,
                  child: SvgPicture.asset(
                    'assets/images/game_memory_number_7/hot_air_balloon.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            )));
  }

  Widget displayCloud() {
    return Stack(
      children: [
        Positioned(
          top: 32 * ratio,
          left: 56 * ratio,
          child: SlideAnimation(
            beginValue: -200 * ratio,
            endValue: screenWidth + 38.0 * ratio,
            time: 45000,
            child: Container(
              height: 108 * ratio,
              width: 190 * ratio,
              child: Image.asset(
                'assets/images/game_memory_number_7/cloud_1.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Positioned(
            top: 146 * ratio,
            left: 667 * ratio,
            child: SlideAnimation(
              beginValue: 300.0 * ratio,
              endValue: -1 * screenWidth,
              time: 35000,
              child: Container(
                height: 58 * ratio,
                width: 110 * ratio,
                child: Image.asset(
                  'assets/images/game_memory_number_7/cloud_2.png',
                  fit: BoxFit.contain,
                ),
              ),
            )),
        Positioned(
            top: 250 * ratio,
            left: 435 * ratio,
            child: SlideAnimation(
              beginValue: screenWidth - 362 * ratio,
              endValue: -1 * screenWidth,
              time: 30000,
              child: Container(
                height: 48 * ratio,
                width: 85 * ratio,
                child: Image.asset(
                  'assets/images/game_memory_number_7/cloud_3.png',
                  fit: BoxFit.contain,
                ),
              ),
            ))
      ],
    );
  }

  Widget displayTutorialWidget() {
    Offset position = Offset(0, 0);
    for (int idx = 0; idx < answerData.length; idx++) {
      ItemModel item = answerData[idx];
      if (item.groupId == questionData.groupId && item.status == 0) {
        position = Offset(item.position.dx * ratio + item.width / 2 * ratio,
            item.position.dy * ratio + item.height / 4 * ratio);
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
    widgets.add(displayCloud());
    widgets.add(displayHotAirBalloon());
    if (isDisplayAnswer) {
      widgets.add(displayAnswer());
    } else {
      widgets.add(displayQuestion());
    }
    widgets.add(BasicItem());
    if (isDisplaySkipScreen) {
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
                      allGameData
                          .gameData[screenModel.currentStep].background)),
                  fit: BoxFit.fill)),
          child: Stack(
            children: displayScreen(),
          ),
        )));
  }
}
