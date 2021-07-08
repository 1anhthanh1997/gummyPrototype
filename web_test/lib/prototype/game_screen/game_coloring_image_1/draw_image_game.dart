import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:svg_path_parser/svg_path_parser.dart';
import 'package:web_test/model/item_model.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/animation_character_item.dart';

class DrawImageGame extends StatefulWidget {
  _DrawImageGameState createState() => _DrawImageGameState();
}

class _DrawImageGameState extends State<DrawImageGame> {
  List<Path> _imagePath = [];
  List<String> imageLink = [];
  List<Offset> imagePosition = [];
  List<String> color = [];
  List<bool> canDraw = [];
  List<int> type = [];

  // List<ItemModel>gameData=[];
  List<ItemModel> imageData = [];
  List data = [];
  List secondData = [];
  List<ItemModel> colorData = [];
  String currentColor = '';
  double bonusHeight;
  List<bool> isCompleted = [];
  List<double> height = [];
  List<double> width = [];
  List<List<Map>> imagePoint = [];
  List<bool> isPlayAnimation = [];
  double screenWidth;
  double screenHeight;
  double ratio;
  ScreenModel screenModel;
  bool isFirstTime = true;
  String assetFolder;
  var fullData;
  int countSum = 0;
  double centerHeight = 0;
  bool isDragging = false;
  int stepIndex = 1;
  int currentColorIndex;
  List<int> status = [];

  Future<void> loadImageData() async {
    var jsonData =
        await rootBundle.loadString('assets/coloring_fruit_data.json');
    fullData = json.decode(jsonData);
    data = fullData['gameData'][1]['items'];
    centerHeight = fullData['gameData'][1]['height'];
    // secondData = fullData['colorItem'];
    assetFolder = fullData['gameAssets'];
    imageData =
        data.map((imageInfo) => new ItemModel.fromJson(imageInfo)).toList();

    for (int index = 0; index < imageData.length; index++) {
      if (imageData[index].type == 1) {
        setState(() {
          colorData.add(imageData[index]);
        });
      } else {
        setState(() {
          imagePoint.add([]);
          _imagePath.add(parseSvgPath(imageData[index].path));
          imageLink.add(assetFolder + imageData[index].image);
          imagePosition.add(imageData[index].position);
          color.add(imageData[index].color);
          canDraw.add(imageData[index].canDraw);
          isCompleted.add(false);
          height.add(imageData[index].height);
          width.add(imageData[index].width);
          type.add(imageData[index].type);
          isPlayAnimation.add(false);
          status.add(0);
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    this.loadImageData();
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
    Timer(Duration(milliseconds: 500), () {
      countingColor();
      editPath();
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    screenWidth = screenModel.getScreenWidth();
    screenHeight = screenModel.getScreenHeight();
    ratio = screenModel.getRatio();
    bonusHeight = (screenHeight - 348 * ratio) / 2;
    super.didChangeDependencies();
  }

  void countingColor() {
    for (int index = 0; index < colorData.length; index++) {
      setState(() {
        countSum += colorData[index].count;
      });
    }
  }

  void editPath() {
    for (int index = 0; index < _imagePath.length; index++) {
      _imagePath[index] = screenModel.scalePath(_imagePath[index]);
    }
  }

  void resetState() {
    setState(() {
      stepIndex++;
      _imagePath = [];
      imageLink = [];
      imagePosition = [];
      color = [];
      canDraw = [];
      type = [];
      imageData = [];
      data = [];
      secondData = [];
      colorData = [];
      currentColor = '';
      isCompleted = [];
      height = [];
      width = [];
      imagePoint = [];
      isPlayAnimation = [];
      status=[];
    });
  }

  void callNextStep() {
    resetState();
    loadImageData();
    setState(() {});
  }

  void onTapDown(Offset position) {
    for (int index = 0; index < _imagePath.length; index++) {
      Offset localOffset = Offset(
          position.dx - imagePosition[index].dx * ratio,
          position.dy -
              imagePosition[index].dy * ratio +
              15 * ratio -
              bonusHeight);
      if (_imagePath[index].contains(localOffset) &&
          color[index] == currentColor &&
          status[index] == 0) {
        setState(() {
          colorData[currentColorIndex].count--;
          countSum--;
          status[index] = 1;
          imageData[index].status = 1;
          isPlayAnimation[index] = true;
          imagePoint[index].add({
            'offset': Offset(
                position.dx - imagePosition[index].dx * ratio,
                position.dy -
                    imagePosition[index].dy * ratio +
                    15 * ratio -
                    bonusHeight),
            'color': HexColor(color[index])
          });
        });
        if (countSum == 0) {
          Timer(Duration(milliseconds: 1000), () {
            callNextStep();
          });
        }
        return;
      }
    }
  }

  Widget displayImage() {
    List<int> imageIndex = Iterable<int>.generate(_imagePath.length).toList();
    imageIndex.sort((a, b) => b.compareTo(a));
    return Stack(
      children: imageIndex.map((index) {
        return type[index] == 0
            ? Positioned(
                top: imagePosition[index].dy * ratio - 15 * ratio + bonusHeight,
                left: imagePosition[index].dx * ratio,
                child: AnimationCharacterItem(
                    imageLink[index],
                    width[index] * ratio,
                    height[index] * ratio,
                    HexColor(color[index]),
                    _imagePath[index],
                    imagePoint[index],
                    isPlayAnimation[index]),
              )
            : Positioned(
                top: imagePosition[index].dy * ratio - 15 * ratio + bonusHeight,
                left: imagePosition[index].dx * ratio,
                child: Container(
                    height: height[index] * ratio,
                    width: width[index] * ratio,
                    child: SvgPicture.asset(imageLink[index])),
              );
      }).toList(),
    );
  }

  Widget displayColor() {
    List<int> colorIndex = Iterable<int>.generate(colorData.length).toList();
    return Stack(
        children: colorIndex.map((colorIndex) {
      ItemModel color = colorData[colorIndex];
      return Positioned(
          top: color.position.dy * ratio - 15 * ratio + bonusHeight,
          left: color.position.dx * ratio,
          child: color.count == 0
              ? Container()
              : GestureDetector(
                  onTapDown: (details) {
                    print(colorIndex);
                    setState(() {
                      currentColor = color.color;
                      currentColorIndex = colorIndex;
                    });
                  },
                  child: Draggable(
                    child: Container(
                        height: color.height * ratio,
                        width: color.width * ratio,
                        child: SvgPicture.asset(
                          assetFolder + color.image,
                          fit: BoxFit.contain,
                          color: HexColor(color.color),
                        )),
                    feedback: Container(
                        height: color.height * ratio,
                        width: color.width * ratio,
                        alignment: Alignment.center,
                        child: Container(
                          height: 50 * ratio,
                          width: 50 * ratio,
                          // alignment: Alignment,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: HexColor(color.color)),
                        )),
                    childWhenDragging: Container(
                        height: color.height * ratio,
                        width: color.width * ratio,
                        child: SvgPicture.asset(assetFolder + color.image,
                            fit: BoxFit.contain, color: HexColor(color.color))),
                    onDragStarted: () {
                      setState(() {
                        currentColor = color.color;
                        currentColorIndex = colorIndex;
                        isDragging = true;
                      });
                    },
                    onDraggableCanceled: (velocity, offset) {
                      onTapDown(Offset(offset.dx + color.width / 2 * ratio,
                          offset.dy + color.height / 2 * ratio));
                    },
                  )));
    }).toList());
  }

  Widget displayBackgroundImage() {
    return Container(
        decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage(assetFolder + fullData['gameData'][0]['background']),
        fit: BoxFit.fill,
      ),
    ));
  }

  Widget displayCounting() {
    List<int> colorIndex = Iterable<int>.generate(colorData.length).toList();
    return Stack(
        children: colorIndex.map((colorIndex) {
      ItemModel color = colorData[colorIndex];
      return Positioned(
          top: color.position.dy * ratio - 15 * ratio + bonusHeight,
          left: color.position.dx * ratio,
          child: color.count == 0
              ? Container()
              : GestureDetector(
                  onTapDown: (details) {
                    setState(() {
                      currentColor = color.color;
                      currentColorIndex = colorIndex;
                    });
                  },
                  child: Container(
                      height: color.height * ratio,
                      width: color.width * ratio,
                      alignment: Alignment.bottomRight,
                      child: Container(
                        height: 22 * ratio,
                        width: 24 * ratio,
                        child: SvgPicture.asset(
                          'assets/images/game_coloring_image_1/counting.svg',
                          fit: BoxFit.contain,
                        ),
                      )),
                ));
    }).toList());
  }

  Widget displayCountingNumber() {
    List<int> colorIndex = Iterable<int>.generate(colorData.length).toList();
    return Stack(
        children: colorIndex.map((colorIndex) {
      ItemModel color = colorData[colorIndex];
      return Positioned(
          top: color.position.dy * ratio - 15 * ratio + bonusHeight,
          left: color.position.dx * ratio,
          child: color.count == 0
              ? Container()
              : GestureDetector(
                  onTapDown: (details) {
                    setState(() {
                      currentColor = color.color;
                      currentColorIndex = colorIndex;
                    });
                  },
                  child: Container(
                      height: color.height * ratio,
                      width: color.width * ratio,
                      alignment: Alignment.bottomRight,
                      child: Container(
                          height: 22 * ratio,
                          width: 24 * ratio,
                          alignment: Alignment.center,
                          child: Text(
                            color.count.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ))),
                ));
    }).toList());
  }

  List<Widget> displayScreen() {
    List<Widget> widgets = [];
    widgets.add(displayBackgroundImage());
    widgets.add(displayImage());
    widgets.add(displayColor());
    widgets.add(displayCounting());
    widgets.add(displayCountingNumber());
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: imageData.length != 0
            ? Container(
                child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapDown: (details) {
                      onTapDown(details.localPosition);
                    },
                    child: Stack(
                      children: displayScreen(),
                    )))
            : Container());
  }
}
