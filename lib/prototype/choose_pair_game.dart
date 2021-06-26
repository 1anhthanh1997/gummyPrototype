import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_test/model/game_calculate_model.dart';
import 'package:web_test/widgets/scale_animation.dart';

class ChoosePairGame extends StatefulWidget {
  _ChoosePairGameState createState() => _ChoosePairGameState();
}

class _ChoosePairGameState extends State<ChoosePairGame> {
  late List data;
  List<GameCalculateModel> itemData = [];
  List<int> draggableKey = [];
  List<int> targetKey = [];
  String assetFolder = '';
  int chosenIndex = -1;

  Future<void> loadGameData() async {
    var jsonData = await rootBundle.loadString('assets/choose_pair_data.json');
    var allGameData = json.decode(jsonData);
    data = allGameData['gameData'][0]['items'];
    assetFolder = allGameData['gameAssets'];
    itemData = data
        .map((itemData) => new GameCalculateModel.fromJson(itemData))
        .toList();
    print(itemData);
  }

  @override
  void initState() {
    super.initState();
    this.loadGameData();
  }

  Widget displayContent() {
    List<int> targetIndex = Iterable<int>.generate(itemData.length).toList();
    return Stack(
      children: targetIndex.map((index) {
        GameCalculateModel item = itemData[index];
        return Positioned(
            left: item.position.dx,
            top: item.position.dy,
            child: item.status == 0
                ? ScaleAnimation(
                    onTab: () {
                      if (chosenIndex == -1) {
                        setState(() {
                          chosenIndex = index;
                        });
                      } else {
                        if (itemData[chosenIndex].groupId == item.groupId) {
                          Timer(Duration(milliseconds: 500),(){
                            setState(() {
                              itemData[chosenIndex].status = 1;
                              itemData[index].status = 1;
                            });
                            setState(() {
                              chosenIndex=-1;
                            });
                          });
                        } else {}
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
                  )
                : Container());
      }).toList(),
    );
  }

  List<Widget> displayScreen() {
    List<Widget> widgets = [];
    widgets.add(displayContent());
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
            ),
    );
  }
}
