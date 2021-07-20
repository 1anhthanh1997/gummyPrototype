import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:scratcher/scratcher.dart';
import 'package:web_test/model/item_model.dart';
import 'package:web_test/model/parent_game_model.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/basic_item.dart';

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

  void loadAlphabetData() {
    stepIndex = screenModel.currentStep;
    allGameData = screenModel.currentGame;
    for (int idx = 0;
    idx < allGameData.gameData[stepIndex].items.length;
    idx++) {
      imageData.add(allGameData.gameData[stepIndex].items[idx].copy());
    }
    assetFolder = screenModel.localPath + allGameData.gameAssets;

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

  @override
  void didChangeDependencies(){
    screenWidth=screenModel.getScreenWidth();
    screenHeight=screenModel.getScreenHeight();
    ratio=screenModel.getRatio();
    super.didChangeDependencies();
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
                child: Image.file(File(assetFolder + item.image)),
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
                  Timer(Duration(milliseconds: 1000), () {
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
                  child: Image.file(File(assetFolder + item.image)),
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

  Widget displayScreen() {
    return Stack(
      children: [scratcher(), BasicItem()],
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
                        image: FileImage(File(assetFolder +
                            allGameData.gameData[stepIndex].background)),
                        fit: BoxFit.fill)),
                child: displayScreen()));
  }
}
