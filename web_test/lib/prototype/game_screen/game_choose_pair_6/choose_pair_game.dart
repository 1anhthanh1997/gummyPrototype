import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_test/model/game_calculate_model.dart';
import 'package:web_test/widgets/basic_item.dart';
import 'package:web_test/widgets/correct_animation.dart';
import 'package:web_test/widgets/scale_animation.dart';

class ChoosePairGame extends StatefulWidget {
  _ChoosePairGameState createState() => _ChoosePairGameState();
}

class _ChoosePairGameState extends State<ChoosePairGame> {
  List data;
  List<GameCalculateModel> itemData = [];
  List<int> draggableKey = [];
  List<int> targetKey = [];
  String assetFolder = '';
  int chosenIndex = -1;
  var allGameData;
  int step = 0;
  List<int> isScale = [];

  Future<void> loadGameData() async {
    var jsonData = await rootBundle.loadString('assets/choose_pair_data.json');
    allGameData = json.decode(jsonData);
    data = allGameData['gameData'][step]['items'];
    assetFolder = allGameData['gameAssets'];
    itemData = data
        .map((itemData) => new GameCalculateModel.fromJson(itemData))
        .toList();
    for(int idx=0;idx<itemData.length;idx++){
      isScale.add(0);
    }
    setState(() {

    });
  }

  @override
  void initState() {
    super.initState();
    this.loadGameData();
  }

  void resetScaleArray(){
    for(int idx=0;idx<isScale.length;idx++){
      isScale[idx]=0;
    }
  }

  Widget displayContent() {
    List<int> targetIndex = Iterable<int>.generate(itemData.length).toList();
    return Stack(
      children: targetIndex.map((index) {
        GameCalculateModel item = itemData[index];
        return item.status == 0
            ? Positioned(
                left: item.position.dx,
                top: item.position.dy - item.height * 0.1,
                child: ScaleAnimation(
                  isPlayAnimation: isScale[index],
                  onTab: () {
                    if (chosenIndex == -1) {
                      setState(() {
                        chosenIndex = index;
                        isScale[index]=1;
                      });
                    } else {
                      if (itemData[chosenIndex].groupId == item.groupId &&
                          index != chosenIndex) {
                        Timer(Duration(milliseconds: 330), () {
                          setState(() {
                            itemData[chosenIndex].status = 1;
                            itemData[index].status = 1;
                            chosenIndex = -1;
                          });
                        });
                      } else {
                        resetScaleArray();
                      }
                    }
                  },
                  child: Container(
                    height: item.height,
                    width: item.width,
                    child: SvgPicture.asset(
                      assetFolder + item.image,
                      fit: BoxFit.contain,
                    ),
                  ),
                ))
            : Positioned(
                left: item.position.dx - item.width * 0.1,
                top: item.position.dy - item.height * 0.2,
                child: CorrectAnimation(
                  isCorrect: item.status == 1,
                  child: Container(
                    height: item.height * 1.2,
                    width: item.width * 1.2,
                    child: SvgPicture.asset(
                      assetFolder + item.image,
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
                    child: SvgPicture.asset(
                      assetFolder + item.image,
                      fit: BoxFit.contain,
                    ),
                  )
                : Container());
      }).toList(),
    );
  }

  Widget displayStep() {
    List<int> imageIndex =
        Iterable<int>.generate(allGameData['gameData'].length).toList();
    return Stack(
      children: imageIndex.map((index) {
        return Positioned(
            top: 9,
            left: 779 - 18.0 * index,
            child: index == step
                ? Container(
                    height: 18,
                    width: 18,
                    child: SvgPicture.asset(
                      'assets/images/common/check.svg',
                      fit: BoxFit.contain,
                    ))
                : Container(
                    height: 18,
                    width: 18,
                    alignment: Alignment.center,
                    child: Container(
                      height: 10,
                      width: 10,
                      child: SvgPicture.asset(
                        'assets/images/common/uncheck.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ));
      }).toList(),
    );
  }

  List<Widget> displayScreen() {
    List<Widget> widgets = [];
    widgets.add(displayContent());
    widgets.add(BasicItem());
    widgets.add(displayStep());
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
                      image: AssetImage(assetFolder +
                          allGameData['gameData'][0]['background']),
                      fit: BoxFit.fill)),
              child: Stack(
                children: displayScreen(),
              ),
            ),
    );
  }
}
