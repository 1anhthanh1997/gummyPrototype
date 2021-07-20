import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:web_test/model/item_model.dart';
import 'package:web_test/model/parent_game_model.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/basic_item.dart';
import 'package:web_test/widgets/bubble_animation.dart';
import 'package:web_test/widgets/opacity_animation.dart';
import 'package:web_test/widgets/particle.dart';
import 'package:web_test/widgets/slide_animation.dart';

class GameMemoryNumber extends StatefulWidget {
  _GameMemoryNumberState createState() => _GameMemoryNumberState();
}

class _GameMemoryNumberState extends State<GameMemoryNumber> {
  List data;
  List<ItemModel> itemData = [];
  List<int> draggableKey = [];
  List<int> targetKey = [];
  String assetFolder = '';
  ItemModel questionData;
  Offset questionPositionTmp = Offset(0, 0);
  List<Offset> answerPositionTmp = [];
  List<ItemModel> answerData = [];
  final List<List<SquareParticle>> particles = [];
  bool isDisplayAnswer = false;
  ParentGameModel allGameData;
  ScreenModel screenModel;
  int count = 0;
  int answerCount = 0;

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
        itemData[index].position = Offset(400, 500);
        questionData = itemData[index];
      } else {
        answerPositionTmp.add(itemData[index].position);
        itemData[index].position = Offset(400, 500);
        answerData.add(itemData[index]);
        particles.add([]);
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
    print(answerCount);
  }

  @override
  void initState() {
    super.initState();
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
    loadGameData();
    Timer(Duration(milliseconds: 500), () {
      questionData.position = questionPositionTmp;
      setState(() {});
    });
    Timer(Duration(milliseconds: 5000), () {
      questionData.position = Offset(questionPositionTmp.dx, -300.0);
      setState(() {});
    });
    Timer(Duration(milliseconds: 5500), () {
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

  Widget _square(int index) {
    ItemModel item = answerData[index];
    return Container(
      height: item.height,
      width: item.width,
      child: SvgPicture.file(
        File(assetFolder + item.image),
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
    if (count == answerCount) {
      Timer(Duration(milliseconds: 2000), () {
        screenModel.nextStep();
      });
    }
    // });
    Iterable.generate(50)
        .forEach((i) => particles[index].add(SquareParticle(time)));
  }

  Widget displayQuestion() {
    return AnimatedPositioned(
        duration: Duration(milliseconds: 1000),
        top: questionData.position.dy,
        left: questionData.position.dx,
        child: BubbleAnimation(
            child: Container(
          height: questionData.height,
          width: questionData.width,
          child: SvgPicture.file(
            File(assetFolder + questionData.image),
            fit: BoxFit.contain,
          ),
        )));
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
                      screenModel.logTapEvent(item.id, details.globalPosition);
                    },
                    onTap: () {
                      _hitSquare(time, index);
                    },
                    child: _square(index))
                : Container(),
            ...particles[index]
                .map((it) => it.buildWidget(time, HexColor(item.color)))
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
        return item.type == 1 && item.groupId == questionData.groupId
            ? AnimatedPositioned(
                left: item.position.dx,
                top: item.position.dy,
                duration: Duration(milliseconds: 1000),
                child: BubbleAnimation(
                  child: _buildParticle(index),
                ))
            : AnimatedPositioned(
                left: item.position.dx,
                top: item.position.dy,
                duration: Duration(milliseconds: 1000),
                child: BubbleAnimation(
                  child: Container(
                    height: item.height,
                    width: item.width,
                    child: SvgPicture.file(
                      File(assetFolder + item.image),
                      fit: BoxFit.contain,
                    ),
                  ),
                ));
      }).toList(),
    );
  }

  Widget displayHotAirBalloon() {
    return Positioned(
        top: 33,
        left: 665,
        child: SlideAnimation(
            beginValue: -900,
            endValue: 250.0,
            time: 40000,
            child: Opacity(
              opacity: 0.75,
              child: BubbleAnimation(
                child: Container(
                  height: 96,
                  width: 71,
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
          top: 32,
          left: 56,
          child: SlideAnimation(
            beginValue: -200,
            endValue: 850.0,
            time: 45000,
            child: Container(
              height: 108,
              width: 190,
              child: Image.asset(
                'assets/images/game_memory_number_7/cloud_1.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Positioned(
            top: 146,
            left: 667,
            child: SlideAnimation(
              beginValue: 300.0,
              endValue: -812.0,
              time: 35000,
              child: Container(
                height: 58,
                width: 110,
                child: Image.asset(
                  'assets/images/game_memory_number_7/cloud_2.png',
                  fit: BoxFit.contain,
                ),
              ),
            )),
        Positioned(
            top: 250,
            left: 435,
            child: SlideAnimation(
              beginValue: 450.0,
              endValue: -812.0,
              time: 30000,
              child: Container(
                height: 48,
                width: 85,
                child: Image.asset(
                  'assets/images/game_memory_number_7/cloud_3.png',
                  fit: BoxFit.contain,
                ),
              ),
            ))
      ],
    );
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

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: itemData.length == 0
            ? Container()
            : Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: FileImage(File(assetFolder +
                            allGameData.gameData[screenModel.currentStep]
                                .background)))),
                child: Stack(
                  children: displayScreen(),
                ),
              ));
  }
}
