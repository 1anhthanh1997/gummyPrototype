import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:svg_path_parser/svg_path_parser.dart';
import 'package:web_test/model/game_data_model.dart';
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
  double bonusHeight=0;

  Future<void> loadAlphabetData() async {
    var jsonData = await rootBundle.loadString('assets/alphabet_j_data.json');
    var allGameData = json.decode(jsonData);
    data = allGameData['gameData'][0]['items'];
    double objectHeight=allGameData['gameData'][0]['height'];
    bonusHeight=50.0;
    alphabetData = data
        .map((alphabetInfo) => new GameDataModel.fromJson(alphabetInfo))
        .toList();
    for (int index = 0; index < alphabetData.length; index++) {
      setState(() {
        _alphabetPoint.add([]);
        alphabetPath.add(parseSvgPath(alphabetData[index].path));
        imageLink.add(allGameData['gameAssets'] + alphabetData[index].image);
        imagePosition.add(alphabetData[index].position);
        startPosition.add(alphabetData[index].startPoint);
        endPosition.add(alphabetData[index].endPoint);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    this.loadAlphabetData().whenComplete(() => {setState(() {})});
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
        position.dy - imagePosition[currentIndex].dy-bonusHeight))) {
      // removePoint();
      setState(() {
        _focusingItem = '';
        // _alphabetPoint=[];
      });
    }
    if (alphabetPath[currentIndex].contains(Offset(
            position.dx - imagePosition[currentIndex].dx,
            position.dy - imagePosition[currentIndex].dy-bonusHeight)) &&
        ((_focusingItem == '' && action == 'start') ||
            _focusingItem == 'alphabet')) {
      if (action != 'start' &&
          !alphabetPath[currentIndex].contains(Offset(
              (position.dx -
                      imagePosition[currentIndex].dx +
                      previousPoint.dx) /
                  2,
              (position.dy -
                      imagePosition[currentIndex].dy-bonusHeight +
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
              position.dy - imagePosition[currentIndex].dy-bonusHeight),
          'color': Colors.red
        });
        previousPoint = Offset(position.dx - imagePosition[currentIndex].dx,
            position.dy - imagePosition[currentIndex].dy-bonusHeight);
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
    return Stack(
      children: indexGenerate.map((index) {
        return Positioned(
            child: CharacterItem(imageLink[index], 213, 284, Colors.red,
                alphabetPath[index], _alphabetPoint[index], isCorrect),
            left: imagePosition[index].dx,
            top: imagePosition[index].dy+bonusHeight);
      }).toList(),
    );
  }

  void onPanStartAction(Offset localPosition) {
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
          isCorrect = true;
        });
      }
    }
  }

  void onPanEndAction() {
    if (currentColor != '') {
      if (!isCorrect) {
        removePoint();
        setState(() {
          isColoringFromStart = false;
        });
      }
      setState(() {
        currentIndex = currentIndex < alphabetData.length - 1
            ? currentIndex + 1
            : currentIndex;
        _focusingItem = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
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
