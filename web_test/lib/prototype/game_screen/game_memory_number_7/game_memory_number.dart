import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:web_test/model/game_calculate_model.dart';
import 'package:web_test/widgets/particle.dart';

class GameMemoryNumber extends StatefulWidget {
  _GameMemoryNumberState createState() => _GameMemoryNumberState();
}

class _GameMemoryNumberState extends State<GameMemoryNumber> {
  List data;
  List<GameCalculateModel> itemData = [];
  List<int> draggableKey = [];
  List<int> targetKey = [];
  String assetFolder = '';
  GameCalculateModel questionData;
  Offset questionPositionTmp = Offset(0, 0);
  List<Offset> answerPositionTmp = [];
  List<GameCalculateModel> answerData = [];
  final List<List<SquareParticle>> particles = [];
  bool isDisplayAnswer=false;

  Future<void> loadGameData() async {
    var directory = await Directory('dir').create(recursive: true);
    print(directory.path);
    var jsonData = await rootBundle.loadString('assets/memory_number.json');
    var allGameData = json.decode(jsonData);
    data = allGameData['gameData'][0]['items'];
    assetFolder = allGameData['gameAssets'];
    itemData = data
        .map((itemData) => new GameCalculateModel.fromJson(itemData))
        .toList();
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
    print(questionData);
  }

  @override
  void initState() {
    super.initState();
    this.loadGameData();
    Timer(Duration(milliseconds: 500), () {
      questionData.position = questionPositionTmp;
      setState(() {});
    });
    Timer(Duration(milliseconds: 4000),(){
      Timer(Duration(milliseconds: 500), () {
        for (int index = 0; index < answerPositionTmp.length; index++) {
          answerData[index].position = answerPositionTmp[index];
        }
        setState(() {
        });
      });
      setState(() {
        isDisplayAnswer=true;
      });
    });
  }

  Widget _square(int index) {
    GameCalculateModel item = answerData[index];
    return Container(
      height: item.height,
      width: item.width,
      child: SvgPicture.asset(
        assetFolder + item.image,
        fit: BoxFit.contain,
      ),
    );
  }

  _hitSquare(Duration time, int index) {
    // _setSquareVisible(false);
    // Timer(Duration(milliseconds: 800),(){
      setState(() {
        answerData[index].status=1;
      });
    // });
    Iterable.generate(50)
        .forEach((i) => particles[index].add(SquareParticle(time)));
  }

  Widget displayQuestion() {
    return AnimatedPositioned(
        duration: Duration(milliseconds: 1000),
        top: questionData.position.dy,
        left: questionData.position.dx,
        child: Container(
          height: questionData.height,
          width: questionData.width,
          child: SvgPicture.asset(
            assetFolder + questionData.image,
            fit: BoxFit.contain,
          ),
        ));
  }

  Widget _buildParticle(int index) {
    GameCalculateModel item =answerData[index];
    return Rendering(
      // onTick: (time) => _manageParticleLife(time),
      builder: (context, time) {
        return Stack(
          overflow: Overflow.visible,
          children: [
            item.status == 0 ?
            GestureDetector(
                onTap: () {
                  _hitSquare(time, index);
                },
                child: _square(index)):Container(),
            ...particles[index].map((it) => it.buildWidget(time,HexColor(item.color)))
          ],
        );
      },
    );
  }

  Widget displayAnswer() {
    List<int> answerIndex = Iterable<int>.generate(answerData.length).toList();
    return Stack(
      children: answerIndex.map((index) {
        GameCalculateModel item = answerData[index];
        return AnimatedPositioned(
            left: item.position.dx,
            top: item.position.dy,
            duration: Duration(milliseconds: 1000),
            child:  _buildParticle(index));
      }).toList(),
    );
  }

  List<Widget> displayScreen() {
    List<Widget> widgets = [];
    if(isDisplayAnswer){
      widgets.add(displayAnswer());
    }else{
      widgets.add(displayQuestion());
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: itemData.length == 0
            ? Container()
            : Container(
                child: Stack(
                  children: displayScreen(),
                ),
              ));
  }
}
