import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:scratcher/scratcher.dart';
import 'package:svg_path_parser/svg_path_parser.dart';
import 'package:web_test/model/game_data_model.dart';
import 'package:web_test/model/item_model.dart';
import 'package:web_test/widgets/character_item.dart';

class GameDragTarget extends StatefulWidget {
  _GameDragTargetState createState() => _GameDragTargetState();
}

class _GameDragTargetState extends State<GameDragTarget>
    with TickerProviderStateMixin {
  List<Path> alphabetPath = [];
  List<List<Map>> _alphabetPoint = [];
  String _focusingItem = '';
  String currentColor = '#000000';
  bool isCorrect = false;
  Offset previousPoint = Offset(0, 0);
  bool isColoringFromStart = false;
  Timer deleteTimer;
  Timer secondDeleteTimer;
  Timer thirdDeleteTimer;
  List data;
  List<GameDataModel> alphabetData = [];
  List<String> imageLink = [];
  List<Offset> imagePosition = [];
  List<Offset> startPosition = [];
  List<Offset> endPosition = [];
  int currentIndex = 0;
  double bonusHeight = 0;
  List<ItemModel> imageData = [];
  var allGameData;
  String assetFolder;
  List<bool> isCompleted = [];
  List<ItemModel> sourceModel = [];
  List<ItemModel> targetModel = [];

  Future<void> loadAlphabetData() async {
    var jsonData = await rootBundle.loadString('assets/alphabet_j_data.json');
    allGameData = json.decode(jsonData);
    data = allGameData['gameData'][2]['items'];
    assetFolder = allGameData['gameAssets'];
    imageData = data
        .map((alphabetInfo) => new ItemModel.fromJson(alphabetInfo))
        .toList();
    for (int idx = 0; idx < imageData.length; idx++) {
      isCompleted.add(false);
    }
    imageData.map((item) {
      if (item.type == 0) {
        targetModel.add(item);
      } else if (item.type == 1) {
        sourceModel.add(item);
      }
      setState(() {});
    }).toList();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    this.loadAlphabetData().whenComplete(() => {setState(() {})});
  }

  Widget displayDraggable() {
    return Stack(
      children: sourceModel.map((item) {
        return Positioned(
            top: item.position.dy,
            left: item.position.dx,
            child: Draggable(
              child: item.status == 1
                  ? Container()
                  : Container(
                      height: item.height * 0.9,
                      width: item.width * 0.9,
                      child: Image.asset(
                        assetFolder + item.image,
                        fit: BoxFit.contain,
                      ),
                    ),
              feedback: Container(
                height: item.height,
                width: item.width,
                child: Image.asset(
                  assetFolder + item.image,
                  fit: BoxFit.contain,
                ),
              ),
              childWhenDragging: Container(),
            ));
      }).toList(),
    );
  }

  Widget displayTarget() {

  }

  List<Widget> displayScreen() {
    List<Widget> widgets = [];
    widgets.add(displayDraggable());
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: imageData.length == 0
            ? Container()
            : Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(assetFolder +
                            allGameData['gameData'][2]['background']),
                        fit: BoxFit.fill)),
                child: Stack(
                  children: displayScreen(),
                )));
  }
}
