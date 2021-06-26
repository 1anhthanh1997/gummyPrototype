import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_test/model/game_calculate_model.dart';

class CalculateGame extends StatefulWidget {
  _CalculateGameState createState() => _CalculateGameState();
}

class _CalculateGameState extends State<CalculateGame> {
  late List data;
  List<GameCalculateModel> itemData = [];
  List<GameCalculateModel> sourceModel = [];
  List<GameCalculateModel> targetModel = [];
  List<int> draggableKey = [];
  List<int> targetKey = [];
  String assetFolder = '';

  Future<void> loadAlphabetData() async {
    var jsonData = await rootBundle.loadString('assets/calculate_game.json');
    var allGameData = json.decode(jsonData);
    data = allGameData['gameData'][0]['items'];
    assetFolder = allGameData['gameAssets'];
    itemData = data
        .map((itemData) => new GameCalculateModel.fromJson(itemData))
        .toList();
    for (int index = 0; index < itemData.length; index++) {
      if (itemData[index].type == 0) {
        setState(() {
          targetModel.add(itemData[index]);
          targetKey.add(itemData[index].id);
        });
      }
      if (itemData[index].type == 1) {
        sourceModel.add(itemData[index]);
        draggableKey.add(itemData[index].id);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    this.loadAlphabetData();
  }

  Widget displayItemImage(double height, double width, String image) {
    return Container(
      height: height,
      width: width,
      child: SvgPicture.asset(
        image,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget displayTarget() {
    List<int> targetIndex = Iterable<int>.generate(targetModel.length).toList();
    return Stack(
      children: targetIndex.map((index) {
        GameCalculateModel item = targetModel[index];
        return Positioned(
            top: item.position.dy,
            left: item.position.dx,
            child: DragTarget<int>(
              builder: (context, candidateData, rejectedData) {
                String fullInitUrl = assetFolder + item.image;
                String fullCompleteUrl = assetFolder + sourceModel[index].image;
                return item.status == 0
                    ? displayItemImage(item.height, item.width, fullInitUrl)
                    : displayItemImage(
                        item.height, item.width, fullCompleteUrl);
              },
              onWillAccept: (data) {
                return data == item.groupId;
              },
              onAccept: (data) {
                setState(() {
                  sourceModel[index].status = 1;
                  targetModel[index].status = 1;
                });
              },
            ));
      }).toList(),
    );
  }

  Widget displayDraggable() {
    List<int> sourceIndex = Iterable<int>.generate(sourceModel.length).toList();
    return Stack(
      children: sourceIndex.map((index) {
        GameCalculateModel item = sourceModel[index];
        String fullInitUrl = assetFolder + item.image;
        return Positioned(
          top: item.position.dy,
          left: item.position.dx,
          child: Draggable(
            data: item.groupId,
            child: item.status == 0
                ? displayItemImage(item.height, item.width, fullInitUrl)
                : Container(),
            feedback: displayItemImage(item.height, item.width, fullInitUrl),
            childWhenDragging: Container(),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> displayScreen() {
    List<Widget> widgets = [];
    widgets.add(displayDraggable());
    widgets.add(displayTarget());
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: Stack(
        children: displayScreen(),
      )),
    );
  }
}
