import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:scratcher/scratcher.dart';
import 'package:web_test/model/item_model.dart';
import 'package:web_test/provider/screen_model.dart';

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
  List data;
  List<ItemModel> alphabetData = [];
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
  List<Offset> positionListTmp = [];
  int count = 0;
  ScreenModel screenModel;
  int stepIndex;

  void loadAlphabetData() {
    stepIndex = screenModel.currentStep;
    allGameData = screenModel.currentGame;
    data = allGameData['gameData'][stepIndex]['items'];
    assetFolder = screenModel.localPath  + allGameData['gameAssets'];
    // assetFolder = allGameData['gameAssets'];
    imageData = data
        .map((alphabetInfo) => new ItemModel.fromJson(alphabetInfo))
        .toList();
    for (int idx = 0; idx < imageData.length; idx++) {
      isCompleted.add(false);
      positionListTmp.add(imageData[idx].position);
      imageData[idx].position = Offset(812 / 2 - 72, 375 / 2 - 72);
      Timer(Duration(milliseconds: (idx + 1) * 500), () {
        setState(() {
          imageData[idx].position = positionListTmp[idx];
        });
      });
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
    loadAlphabetData();
  }

  Widget displayScratcherItem(ItemModel item, int index) {
    return isCompleted[index]
        ? Positioned(
            top: item.position.dy,
            left: item.position.dx,
            child: Container(
              height: 144,
              width: 144,
              alignment: Alignment.center,
              child: Container(
                height: item.height,
                width: item.width,
                child: Image.asset(assetFolder + item.image),
              ),
            ),
          )
        : AnimatedPositioned(
            top: item.position.dy,
            left: item.position.dx,
            duration: Duration(milliseconds: 500),
            child: Scratcher(
              brushSize: 30,
              threshold: 70,
              color: HexColor('#00FFFFFF'),
              image: Image.asset(
                'assets/images/game_draw_alphabet_3/draw_A/scratcher.png',
                fit: BoxFit.fill,
              ),
              onChange: (value) => print("Scratch progress: $value%"),
              onThreshold: () {
                setState(() {
                  isCompleted[index] = true;
                  count++;
                });
                if (count == isCompleted.length) {
                  Timer(Duration(milliseconds: 1000),(){
                    screenModel.nextStep();
                  });
                }
              },
              child: Container(
                height: 144,
                width: 144,
                alignment: Alignment.center,
                child: Container(
                  height: item.height,
                  width: item.width,
                  child: Image.asset(assetFolder + item.image),
                ),
              ),
            ));
  }

  Widget scratcher() {
    List<int> imageIndex = Iterable<int>.generate(imageData.length).toList();
    return Stack(
      children: imageIndex.map((index) {
        return displayScratcherItem(imageData[index], index);
      }).toList(),
    );
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
                            allGameData['gameData'][stepIndex]['background']),
                        fit: BoxFit.fill)),
                child: scratcher()));
  }
}
