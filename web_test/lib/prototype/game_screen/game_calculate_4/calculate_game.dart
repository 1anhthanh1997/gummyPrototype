import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:web_test/model/game_calculate_model.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/animated_matched_target.dart';
import 'package:web_test/widgets/animation_draggable_tap.dart';
import 'package:web_test/widgets/animation_hit_fail.dart';

class CalculateGame extends StatefulWidget {
  _CalculateGameState createState() => _CalculateGameState();
}

class _CalculateGameState extends State<CalculateGame> {
  List data;
  List<GameCalculateModel> itemData = [];
  List<GameCalculateModel> sourceModel = [];
  List<GameCalculateModel> targetModel = [];
  List<GameCalculateModel> normalItemModel = [];
  List<int> draggableKey = [];
  List<int> targetKey = [];
  String assetFolder = '';
  bool isHitFail = false;
  bool isWrongTarget = false;
  ScreenModel screenModel;
  double screenWidth;
  double screenHeight;
  double ratio;
  double bonusHeight;

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
      if (itemData[index].type == 2) {
        normalItemModel.add(itemData[index]);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    this.loadAlphabetData();
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenHeight = screenModel.getScreenHeight();
    screenWidth = screenModel.getScreenWidth();
    ratio = screenModel.getRatio();
    bonusHeight = (screenHeight - 111 * ratio) / 2;
    print(ratio);
  }

  double getBiggerSpace(Offset offsetSource, Offset offset) {
    double verticalSpace = offsetSource.dy - offset.dy > 0
        ? offsetSource.dy - offset.dy
        : offset.dy - offsetSource.dy;
    double horizontalSpace = offsetSource.dx - offset.dx > 0
        ? offsetSource.dx - offset.dx
        : offset.dx - offsetSource.dx;
    double denta =
        verticalSpace > horizontalSpace ? verticalSpace : horizontalSpace;
    return denta;
  }

  int editValue(int val) {
    if (val >= 0)
      return val;
    else
      return -1 * val;
  }

  void onDraggableCancelled(GameCalculateModel item, Offset offset) {
    if (isWrongTarget) {
      Offset offsetSource = item.position;
      item.position = Offset(offset.dx / ratio, offset.dy / ratio);
      setState(() {
        isHitFail = true;
      });
      Timer(Duration(milliseconds: 200), () {
        setState(() {
          isHitFail = false;
          isWrongTarget = false;
        });
      });
      Timer(Duration(milliseconds: 800), () {
        double denta = getBiggerSpace(offsetSource, offset);
        if (denta < 200 && item.status == 0) {
          denta = 200;
        }
        item.duration = editValue(denta.toInt());
        item.position = offsetSource;
        setState(() {});
      });
    } else {
      Offset offsetSource = item.position;
      item.position = Offset(offset.dx / ratio, offset.dy / ratio);
      setState(() {});
      Timer(Duration(milliseconds: 50), () {
        double denta = getBiggerSpace(offsetSource, offset);
        if (denta < 200 && item.status == 0) {
          denta = 200;
        }
        item.duration = editValue(denta.toInt());
        item.position = offsetSource;
        setState(() {});
      });
    }
  }

  Widget displayItemImage(double height, double width, String image) {
    return Container(
      height: height * ratio,
      width: width * ratio,
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
            top: item.position.dy * ratio - 139 * ratio + bonusHeight,
            left: item.position.dx * ratio,
            child: DragTarget<int>(
              builder: (context, candidateData, rejectedData) {
                String fullInitUrl = assetFolder + item.image;
                String fullCompleteUrl = assetFolder + sourceModel[index].image;
                return item.status == 0
                    ? displayItemImage(item.height, item.width, fullInitUrl)
                    : AnimatedMatchedTarget(
                        child: displayItemImage(
                            item.height, item.width, fullCompleteUrl),
                      );
              },
              onWillAccept: (data) {
                return data == item.groupId;
              },
              onLeave: (data) {
                setState(() {
                  isWrongTarget = true;
                });
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
        return AnimatedPositioned(
            duration: Duration(milliseconds: item.duration),
            top: item.position.dy * ratio,
            left: item.position.dx * ratio,
            child: AnimationDraggableTap(
              child: Draggable(
                data: item.groupId,
                child: AnimationHitFail(
                  isDisplayAnimation: isHitFail,
                  child: item.status == 0
                      ? displayItemImage(item.height, item.width, fullInitUrl)
                      : Container(),
                ),
                feedback:
                    displayItemImage(item.height, item.width, fullInitUrl),
                childWhenDragging: Container(),
                onDragStarted: () {
                  item.duration = 0;
                },
                maxSimultaneousDrags: 1,
                onDraggableCanceled: (velocity, offset) {
                  onDraggableCancelled(item, offset);
                },
              ),
            ));
      }).toList(),
    );
  }

  Widget displayNormalItem() {
    return Stack(
        children: normalItemModel.map((item) {
      return Positioned(
          top: item.position.dy * ratio,
          left: item.position.dx * ratio,
          child: Container(
            height: item.height * ratio,
            width: item.width * ratio,
            child: SvgPicture.asset(
              assetFolder + item.image,
              fit: BoxFit.contain,
            ),
          ));
    }).toList());
  }

  List<Widget> displayScreen() {
    List<Widget> widgets = [];
    widgets.add(displayNormalItem());
    widgets.add(displayTarget());
    widgets.add(displayDraggable());
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: HexColor('#DE2463'),
          child: Stack(
            children: displayScreen(),
          )),
    );
  }
}
