import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_test/model/game_classify_model.dart';
import 'package:web_test/model/item_model.dart';
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

  Future<void> loadClassifyData() async {
    var jsonData =
        await rootBundle.loadString('assets/classify_game_data.json');
    data = json.decode(jsonData);
    List draggable = data['gameData'][0]['items'];
    assetFolder = data['gameAssets'];
    print(draggable);
    items = draggable
        .map((classifyInfo) => new ItemModel.fromJson(classifyInfo))
        .toList();
    setState(() {});
    print(items);
  }

  @override
  void initState() {
    this.loadClassifyData();
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 3000));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _transAnimation = Tween(begin: -300.0, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.75, curve: Curves.linear),
      ),
    );

    controller.forward();
  }

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

  Widget displayFirstDraggableItem(ItemModel item) {
    print(item.image);
    Offset position = item.position;

    return AnimatedPositioned(
      top: position.dy,
      left: position.dx,
      curve: Curves.linear,
      duration: Duration(milliseconds: durationTime),
      child: item.status == 1
          ? CorrectAnimation(
              isCorrect: item.status == 1,
              child: Container(
                height: item.height,
                width: item.width,
                child: SvgPicture.asset(
                  assetFolder + item.image,
                  fit: BoxFit.contain,
                ),
              ))
          : Draggable(
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
              maxSimultaneousDrags: 1,
              onDraggableCanceled: (velocity, offset) {
                Offset offsetSource;
                if (offset.dx <= 812 / 2 - 812 / 14 - 30 && item.groupId == 0) {
                  offsetSource = item.endPosition;
                  setState(() {
                    item.status = 1;
                  });
                  Timer(Duration(milliseconds: 600), () {
                    for (int idx = item.id + 1; idx < items.length; idx++) {
                      if (!(item.status == 1)) {
                        print(idx);
                        items[idx].position = Offset(items[idx].position.dx,
                            items[idx].position.dy - 100);
                      }
                    }
                    setState(() {});
                  });
                } else if (offset.dx >= 812 / 2 + 812 / 14 &&
                    item.groupId == 1) {
                  offsetSource = item.endPosition;
                  setState(() {
                    item.status = 1;
                  });
                  Timer(Duration(milliseconds: 600), () {
                    for (int idx = item.id + 1; idx < items.length; idx++) {
                      if (!(item.status == 1)) {
                        print(idx);
                        items[idx].position = Offset(items[idx].position.dx,
                            items[idx].position.dy - 100);
                      }
                    }
                    setState(() {});
                  });
                } else {
                  offsetSource = item.position;
                }
                item.position = offset;
                setState(() {});
                Timer(Duration(milliseconds: 50), () {
                  durationTime = 800;
                  item.position = offsetSource;
                  setState(() {});
                });
              },
            ),
    );
  }

  Widget displayDraggableItem() {
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
                children: items.map((item) {
          return item.type == 1 ? displayFirstDraggableItem(item) : Container();
        }).toList())));
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
                  child: SvgPicture.asset(assetFolder + item.image,
                      fit: BoxFit.contain),
                ))
            : Container();
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
                  displayNormalItem(),
                  displayDraggableItem()
                ],
              ),
            ),
    );
  }
}
