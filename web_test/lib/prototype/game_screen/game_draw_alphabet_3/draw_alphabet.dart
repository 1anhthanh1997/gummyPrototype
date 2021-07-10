import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scratcher/scratcher.dart';
import 'package:svg_path_parser/svg_path_parser.dart';
import 'package:web_test/model/item_model.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/character_item.dart';

class DrawAlphabet extends StatefulWidget {
  _DrawAlphabetState createState() => _DrawAlphabetState();
}

class _DrawAlphabetState extends State<DrawAlphabet>
    with TickerProviderStateMixin {
  List<Path> alphabetPath = [];
  List<List<Map>> _alphabetPoint = [];
  String _focusingItem = '';
  String currentColor = '#000000';

  // bool isCorrect = false;
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
  var allGameData;
  var assetFolder;
  ScreenModel screenModel;

  Future<void> loadAlphabetData() async {
    var jsonData = await rootBundle.loadString('assets/alphabet_j_data.json');
    allGameData = json.decode(jsonData);
    data = allGameData['gameData'][0]['items'];
    double objectHeight = allGameData['gameData'][0]['height'];
    assetFolder = allGameData['gameAssets'];
    bonusHeight = 0.0;
    alphabetData = data
        .map((alphabetInfo) => new ItemModel.fromJson(alphabetInfo))
        .toList();
    // print(screenModel.localPath);
    for (int index = 0; index < alphabetData.length; index++) {
      setState(() {
        _alphabetPoint.add([]);
        alphabetPath.add(parseSvgPath(alphabetData[index].path));
        imageLink.add(screenModel.localPath +
            allGameData['gameAssets'] +
            alphabetData[index].image);
        imagePosition.add(alphabetData[index].position);
        startPosition.add(alphabetData[index].startPosition);
        endPosition.add(alphabetData[index].endPosition);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    this.loadAlphabetData().whenComplete(() => {setState(() {})});
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
  }

  removePoint() {
    if (!(_alphabetPoint[currentIndex].length == 0)) {
      deleteTimer = Timer.periodic(Duration(milliseconds: 10), (timer) {
        if (_alphabetPoint[currentIndex].length == 0) {
          deleteTimer.cancel();
          return;
        }
        _alphabetPoint[currentIndex]
            .removeAt(_alphabetPoint[currentIndex].length - 1);
        setState(() {});
      });
    }
  }

  addPoints(String action, Offset position) {
    if (!alphabetPath[currentIndex].contains(Offset(
        position.dx - imagePosition[currentIndex].dx,
        position.dy - imagePosition[currentIndex].dy - bonusHeight))) {
      // removePoint();
      setState(() {
        _focusingItem = '';
        // _alphabetPoint=[];
      });
    }
    if (alphabetPath[currentIndex].contains(Offset(
            position.dx - imagePosition[currentIndex].dx,
            position.dy - imagePosition[currentIndex].dy - bonusHeight)) &&
        ((_focusingItem == '' && action == 'start') ||
            _focusingItem == 'alphabet')) {
      if (action != 'start' &&
          !alphabetPath[currentIndex].contains(Offset(
              (position.dx -
                      imagePosition[currentIndex].dx +
                      previousPoint.dx) /
                  2,
              (position.dy -
                      imagePosition[currentIndex].dy -
                      bonusHeight +
                      previousPoint.dy) /
                  2))) {
        removePoint();
        setState(() {
          isColoringFromStart = false;
        });
        return;
      }
      setState(() {
        _alphabetPoint[currentIndex].add({
          'offset': Offset(position.dx - imagePosition[currentIndex].dx,
              position.dy - imagePosition[currentIndex].dy - bonusHeight),
          'color': Colors.red
        });
        previousPoint = Offset(position.dx - imagePosition[currentIndex].dx,
            position.dy - imagePosition[currentIndex].dy - bonusHeight);
      });
      if (action == 'start') {
        setState(() {
          isColoringFromStart = true;
          _focusingItem = 'alphabet';
        });
      }
    }
  }

  Widget displayAlphabet() {
    List<int> indexGenerate =
        Iterable<int>.generate(alphabetData.length).toList();
    indexGenerate.sort((a, b) => b.compareTo(a));
    return Stack(
      children: indexGenerate.map((index) {
        return Positioned(
            child: CharacterItem(
                imageLink[index],
                alphabetData[index].width,
                alphabetData[index].height,
                Colors.red,
                alphabetPath[index],
                _alphabetPoint[index],
                alphabetData[index].status == 1),
            left: imagePosition[index].dx,
            top: imagePosition[index].dy + bonusHeight);
      }).toList(),
    );
  }

  void onPanStartAction(Offset localPosition) {
    // print(localPosition);
    // print(startPosition[currentIndex]);

    if (currentColor != '' &&
        localPosition.dx < startPosition[currentIndex].dx + 50 &&
        localPosition.dx > startPosition[currentIndex].dx &&
        localPosition.dy > startPosition[currentIndex].dy &&
        localPosition.dy < startPosition[currentIndex].dy + 50) {
      addPoints('start', localPosition);
    }
  }

  void onPanUpdateAction(Offset localPosition) {
    if (currentColor != '') {
      addPoints('update', localPosition);
      // print(localPosition);
      if (localPosition.dx < endPosition[currentIndex].dx + 70 &&
          localPosition.dx > endPosition[currentIndex].dx &&
          localPosition.dy < endPosition[currentIndex].dy + 60 &&
          localPosition.dy > endPosition[currentIndex].dy &&
          isColoringFromStart &&
          _alphabetPoint[currentIndex].length > 2) {
        setState(() {
          alphabetData[currentIndex].status = 1;
        });
      }
    }
  }

  void onPanEndAction() {
    if (currentColor != '') {
      if (alphabetData[currentIndex].status == 0) {
        removePoint();
        setState(() {
          isColoringFromStart = false;
        });
      } else {
        if (currentIndex == alphabetData.length - 1) {
          screenModel.nextStep();
        }
        setState(() {
          currentIndex = currentIndex < alphabetData.length - 1
              ? currentIndex + 1
              : currentIndex;
          _focusingItem = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: alphabetData.length == 0
            ? Container()
            : Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(screenModel.localPath +
                            assetFolder +
                            allGameData['gameData'][0]['background']),
                        fit: BoxFit.fill)),
                child: alphabetData.length != 0
                    ? GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onPanStart: (details) {
                          onPanStartAction(details.localPosition);
                        },
                        onPanUpdate: (details) {
                          onPanUpdateAction(details.localPosition);
                        },
                        onPanEnd: (details) {
                          onPanEndAction();
                        },
                        child: displayAlphabet())
                    : Container()));
  }
}
