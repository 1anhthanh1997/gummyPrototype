import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_test/model/game_classify_model.dart';
import 'package:web_test/model/item_model.dart';
import 'package:web_test/widgets/basic_item.dart';
import 'package:web_test/widgets/correct_animation.dart';

class ClassifyItem extends StatefulWidget {
  @override
  _ClassifyItemState createState() => _ClassifyItemState();
}

class _ClassifyItemState extends State<ClassifyItem>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  List<bool> isAccepted = [false, false, false, false];
  Offset firstOffset = Offset(812 / 2 - 30, 375 / 2 - 30);
  int durationTime = 0;
  AnimationController controller;
  List<ItemModel> items = [];
  Animation<double> _transAnimation;
  var data;
  List<GameClassifyModel> classifyData = [];
  String assetFolder;
  int step = 0;
  List<bool> isSelected = [false, false];

  Future<void> loadClassifyData() async {
    var jsonData =
        await rootBundle.loadString('assets/classify_game_data.json');
    data = json.decode(jsonData);
    List draggable = data['gameData'][0]['items'];
    assetFolder = data['gameAssets'];
    items = draggable
        .map((classifyInfo) => new ItemModel.fromJson(classifyInfo))
        .toList();
    setState(() {});
  }

  @override
  void initState() {
    this.loadClassifyData();
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _transAnimation = Tween(begin: -500.0, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.75, curve: Curves.easeInOutBack),
      ),
    );

    controller.forward();
  }

  void fallItem(int index) {
    for (int idx = 0; idx < index; idx++) {
      items[idx].position =
          Offset(items[idx].position.dx, items[idx].position.dy + 100);
    }
  }

  void callOnDraggableCancelled(ItemModel item, int index, Offset offset) {}

  Widget displayBackground() {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                assetFolder + data['gameData'][0]['background'],
              ),
              fit: BoxFit.fill)),
    );
  }

  Widget displayNotCompleteDraggable(ItemModel item, int index) {
    return Draggable(
      data: 0,
      child: Container(
        height: item.height,
        width: item.width,
        child: SvgPicture.asset(
          assetFolder + item.image,
          fit: BoxFit.contain,
        ),
      ),
      feedback: Container(
        height: item.height,
        width: item.width,
        child: SvgPicture.asset(
          assetFolder + item.image,
          fit: BoxFit.contain,
        ),
      ),
      childWhenDragging: Container(),
      onDragStarted: () {
        durationTime = 0;
      },
      onDragUpdate: (details) {
        Offset offset = details.globalPosition;
        if (offset.dx <= 812 / 2 - 812 / 14 - 30) {
          setState(() {
            isSelected[0] = true;
            isSelected[1] = false;
          });
        } else if (offset.dx >= 812 / 2 + 812 / 14) {
          setState(() {
            isSelected[0] = false;
            isSelected[1] = true;
          });
        } else {
          setState(() {
            isSelected[0] = false;
            isSelected[1] = false;
          });
        }
      },
      maxSimultaneousDrags: 1,
      onDraggableCanceled: (velocity, offset) {
        Offset offsetSource;
        if (offset.dx <= 812 / 2 - 812 / 14 - 30 && item.groupId == 0) {
          offsetSource = item.endPosition;
          setState(() {
            item.status = 1;
          });
        } else if (offset.dx >= 812 / 2 + 812 / 14 && item.groupId == 1) {
          offsetSource = item.endPosition;
          setState(() {
            item.status = 1;
          });
        } else {
          offsetSource = item.position;
        }
        item.position = offset;
        setState(() {});
        Timer(Duration(milliseconds: 50), () {
          if (item.status == 1) {
            fallItem(index);
          }
          durationTime = 300;
          item.position = offsetSource;
          Timer(Duration(milliseconds: 1700), () {
            isSelected[item.groupId] = false;
            setState(() {});
          });
          setState(() {});
        });
      },
    );
  }

  Widget displayCompleteDraggable(ItemModel item, int index) {
    return CorrectAnimation(
        isCorrect: item.status == 1,
        child: Container(
          height: item.height,
          width: item.width,
          child: SvgPicture.asset(
            assetFolder + item.image,
            fit: BoxFit.contain,
          ),
        ));
  }

  Widget displayFirstDraggableItem(ItemModel item, int index) {
    Offset position = item.position;
    return AnimatedPositioned(
        top: position.dy,
        left: position.dx,
        curve: Curves.linear,
        duration: Duration(milliseconds: durationTime),
        child: item.status == 1
            ? displayCompleteDraggable(item, index)
            : displayNotCompleteDraggable(item, index));
  }

  Widget displayDraggableItem() {
    List<int> imageIndex = Iterable<int>.generate(items.length).toList();
    return AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _transAnimation.value),
            child: child,
          );
        },
        child: Container(
            child: Stack(
                children: imageIndex.map((index) {
          ItemModel item = items[index];
          return item.type == 1
              ? displayFirstDraggableItem(item, index)
              : Container();
        }).toList())));
  }

  Widget displayTargetItem() {
    return Stack(
      children: items.map((item) {
        return item.type == 0
            ? Positioned(
                top: isSelected[item.groupId]
                    ? item.position.dy - 10
                    : item.position.dy,
                left: isSelected[item.groupId]
                    ? item.position.dx - 10
                    : item.position.dx,
                child: Container(
                  width:
                      isSelected[item.groupId] ? item.width + 20 : item.width,
                  height:
                      isSelected[item.groupId] ? item.height + 20 : item.height,
                  child: Image.asset(assetFolder + item.image,
                      fit: BoxFit.contain),
                ))
            : Container();
      }).toList(),
    );
  }

  Widget displayNormalItem() {
    return Stack(
        children: items.map((item) {
      return item.type == 2
          ? Positioned(
              top: item.position.dy,
              left: item.position.dx,
              child: Container(
                width: item.width,
                height: item.height,
                child:
                    Image.asset(assetFolder + item.image, fit: BoxFit.contain),
              ))
          : Container();
    }).toList());
  }

  Widget displayStep() {
    List<int> imageIndex =
        Iterable<int>.generate(data['gameData'].length).toList();
    return Stack(
      children: imageIndex.map((index) {
        return Positioned(
            top: 9,
            left: 779 - 18.0 * index,
            child: index == step
                ? Container(
                    height: 18,
                    width: 18,
                    child: SvgPicture.asset(
                      'assets/images/common/check.svg',
                      fit: BoxFit.contain,
                    ))
                : Container(
                    height: 18,
                    width: 18,
                    alignment: Alignment.center,
                    child: Container(
                      height: 10,
                      width: 10,
                      child: SvgPicture.asset(
                        'assets/images/common/uncheck.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ));
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: data == null
          ? Container()
          : Container(
              child: Stack(
                children: [
                  displayBackground(),
                  BasicItem(),
                  displayStep(),
                  displayNormalItem(),
                  displayTargetItem(),
                  displayDraggableItem()
                ],
              ),
            ),
    );
  }
}
