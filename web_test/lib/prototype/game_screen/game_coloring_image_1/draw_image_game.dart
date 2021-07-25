import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:svg_path_parser/svg_path_parser.dart';
import 'package:web_test/model/item_model.dart';
import 'package:web_test/model/parent_game_model.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/animation_character_item.dart';
import 'package:web_test/widgets/basic_item.dart';
import 'package:web_test/widgets/tutorial_widget.dart';

class DrawImageGame extends StatefulWidget {
  DrawImageGame({Key key}) : super(key: key);

  _DrawImageGameState createState() => _DrawImageGameState();
}

class _DrawImageGameState extends State<DrawImageGame> {
  List<Path> _imagePath = [];
  List<String> imageLink = [];
  List<Offset> imagePosition = [];
  List<String> color = [];
  List<bool> canDraw = [];
  List<int> type = [];
  List<ItemModel> imageData = [];
  List<ItemModel> data = [];
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
  int currentColorIndex;
  List<int> status = [];
  ParentGameModel currentGameData;
  List<int> id = [];
  int stepIndex;
  bool isDisplayTutorialWidget = false;
  Timer timer;

  void loadImageData() {
    currentGameData = screenModel.currentGame;
    stepIndex = screenModel.currentStep;
    for (int idx = 0;
        idx < currentGameData.gameData[stepIndex].items.length;
        idx++) {
      imageData.add(currentGameData.gameData[stepIndex].items[idx].copy());
    }
    // centerHeight = currentGameData.gameData[stepIndex];
    centerHeight = 0;
    assetFolder = screenModel.localPath + currentGameData.gameAssets;
    // assetFolder = currentGameData.gameAssets;

    for (int index = 0; index < imageData.length; index++) {
      if (imageData[index].type == 1) {
        // print(imageData[index].count);
        setState(() {
          colorData.add(imageData[index]);
        });
      } else {
        setState(() {
          id.add(imageData[index].id);
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
    setState(() {
      currentColor = colorData[0].color;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
    loadImageData();
    _initializeTimer();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    screenWidth = screenModel.getScreenWidth();
    screenHeight = screenModel.getScreenHeight();
    ratio = screenModel.getRatio();
    bonusHeight = (screenHeight - 348 * ratio) / 2;
    countingColor();
    editPath();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
   if(timer!=null){
     timer.cancel();
   }
    super.dispose();
  }

  void _initializeTimer() {
    timer = Timer.periodic(new Duration(seconds: 7), (timer) {
      setState(() {
        isDisplayTutorialWidget = true;
      });
    });
  }

  void onPointerTap(PointerEvent details) {
    if (!timer.isActive) {
      return;
    }
    setState(() {
      isDisplayTutorialWidget=false;
    });
    timer.cancel();
    _initializeTimer();
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
      status = [];
    });
  }

  void callNextStep() {
    screenModel.nextStep();
    if(screenModel.currentStep!=0){
      resetState();
      loadImageData();
    }else{
      if(timer!=null){
        timer.cancel();
      }
    }
    setState(() {});
  }

  void onChooseColoringImage(Offset position, int type) {
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
        if (type == 0) {
          screenModel.logTapEvent(id[index], position);
        } else {
          screenModel.endPositionId = id[index];
          screenModel.logDragEvent(true);
        }
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
        // for (int index = 0; index < imageData.length; index++) {
        //   if (imageData[index].type == 1) {
        //     print(currentGameData.gameData[stepIndex].items[index].count);
        //   }
        // }
        if (countSum == 0) {
          Timer(Duration(milliseconds: 1000), () {
            callNextStep();
          });
        }
        return;
      } else {
        if (type == 0) {
          screenModel.logTapEvent(-1, position);
        } else {
          screenModel.endPositionId = -1;
          screenModel.logDragEvent(false);
        }
      }
    }
  }

  Widget displayImage() {
    List<int> imageIndex = Iterable<int>.generate(_imagePath.length).toList();
    imageIndex.sort((a, b) => b.compareTo(a));
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (details) {
          onChooseColoringImage(details.globalPosition, 0);
        },
        child: Stack(
          children: imageIndex.map((index) {
            return type[index] == 0
                ? Positioned(
                    top: imagePosition[index].dy * ratio -
                        15 * ratio +
                        bonusHeight,
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
                    top: imagePosition[index].dy * ratio -
                        15 * ratio +
                        bonusHeight,
                    left: imagePosition[index].dx * ratio,
                    child: Container(
                        height: height[index] * ratio,
                        width: width[index] * ratio,
                        child: SvgPicture.file(File(imageLink[index]))),
                  );
          }).toList(),
        ));
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
                    screenModel.logTapEvent(color.id, details.globalPosition);
                    setState(() {
                      currentColor = color.color;
                      currentColorIndex = colorIndex;
                    });
                  },
                  child: Draggable(
                    child: Container(
                        height: color.height * ratio,
                        width: color.width * ratio,
                        child: SvgPicture.file(
                          File(assetFolder + color.image),
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
                        child: SvgPicture.file(File(assetFolder + color.image),
                            fit: BoxFit.contain, color: HexColor(color.color))),
                    onDragStarted: () {
                      screenModel.startPositionId = color.id;
                      screenModel.startPosition = color.position;
                      setState(() {
                        currentColor = color.color;
                        currentColorIndex = colorIndex;
                        isDragging = true;
                      });
                    },
                    onDraggableCanceled: (velocity, offset) {
                      screenModel.endPosition = offset;
                      onChooseColoringImage(
                          Offset(offset.dx + color.width / 2 * ratio,
                              offset.dy + color.height / 2 * ratio),
                          1);
                    },
                  )));
    }).toList());
  }

  Widget displayBackgroundImage() {
    return Container(
        decoration: BoxDecoration(
      image: DecorationImage(
        image: FileImage(
            File(assetFolder + currentGameData.gameData[stepIndex].background)),
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
                    screenModel.logTapEvent(color.id, details.globalPosition);
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
                    screenModel.logTapEvent(color.id, details.globalPosition);
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
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15 * ratio),
                          ))),
                ));
    }).toList());
  }

  Widget displayTutorialWidget() {
    int currentItemIndex = 0;
    for (int idx = 0; idx < color.length; idx++) {
      if (color[idx] == currentColor && status[idx] == 0) {
        currentItemIndex = idx;
        break;
      }
    }
    // print('ItemIndex');
    // print(imagePosition[currentItemIndex]);
    Offset endPosition = Offset(
        imagePosition[currentItemIndex].dx * ratio +
            width[currentItemIndex] / 2 * ratio,
        imagePosition[currentItemIndex].dy * ratio -
            15 * ratio +
            bonusHeight +
            height[currentItemIndex] / 2 * ratio);
    return isDisplayTutorialWidget
        ? TutorialWidget(
            startPosition: Offset(0, 0),
            endPosition: endPosition,
            onCompleted: () {
              Timer(Duration(milliseconds: 200), () {
                setState(() {
                  isDisplayTutorialWidget = false;
                });
              });
            },
          )
        : Container();
  }

  List<Widget> displayScreen() {
    List<Widget> widgets = [];
    widgets.add(displayBackgroundImage());
    widgets.add(displayImage());
    widgets.add(displayColor());
    widgets.add(displayCounting());
    widgets.add(displayCountingNumber());
    widgets.add(BasicItem());
    widgets.add(displayTutorialWidget());
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerDown: onPointerTap,
        onPointerMove: onPointerTap,
        onPointerUp: onPointerTap,
        child: Scaffold(
            body: imageData.length != 0
                ? Container(
                    child: Stack(
                    children: displayScreen(),
                  ))
                : Container()));
  }
}
