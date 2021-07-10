import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:scratcher/scratcher.dart';
import 'package:svg_path_parser/svg_path_parser.dart';
import 'package:web_test/model/game_data_model.dart';
import 'package:web_test/model/item_model.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/character_item.dart';

class ScratcherGame extends StatefulWidget {
  _ScratcherGameState createState() => _ScratcherGameState();
}

class _ScratcherGameState extends State<ScratcherGame>
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
  int count=0;
  ScreenModel screenModel;

  Future<void> loadAlphabetData() async {
    var jsonData = await rootBundle.loadString('assets/alphabet_j_data.json');
    allGameData = json.decode(jsonData);
    data = allGameData['gameData'][1]['items'];
    assetFolder = allGameData['gameAssets'];
    imageData = data
        .map((alphabetInfo) => new ItemModel.fromJson(alphabetInfo))
        .toList();
    for (int idx = 0; idx < imageData.length; idx++) {
      isCompleted.add(false);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    this.loadAlphabetData().whenComplete(() => {setState(() {})});
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
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
        : Positioned(
            top: item.position.dy,
            left: item.position.dx,
            child: Scratcher(
              brushSize: 30,
              threshold: 70,
              color: HexColor('#00FFFFFF'),
              image: Image.asset(
                'assets/images/game_draw_alphabet_3/draw_A/scratcher.png',
                fit: BoxFit.fill,
              ),
              onChange: (value) => print("Scratch progress: $value%"),
              onThreshold: (){
                setState(() {
                  isCompleted[index] = true;
                  count++;
                });
                if(count==isCompleted.length){
                  screenModel.nextStep();
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
                            allGameData['gameData'][1]['background']),
                        fit: BoxFit.fill)),
                child: scratcher()));
  }
}
