import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_test/model/game_classify_model.dart';
import 'package:web_test/model/item_model.dart';

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
  List<GameClassifyModel> items = [];
   Animation<double> _transAnimation;
   var data;
  List<GameClassifyModel> classifyData = [];

  Future<void> loadClassifyData() async {
    var jsonData =
        await rootBundle.loadString('assets/classify_game_data.json');
    data = json.decode(jsonData);
    List draggable = data['draggable'];
    print(draggable);
    items = draggable
        .map((classifyInfo) => new GameClassifyModel.fromJson(classifyInfo))
        .toList();
    print(items);
  }

  @override
  void initState() {
    this.loadClassifyData();
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _transAnimation = Tween(begin: 600.0, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.75, curve: Curves.easeOutBack),
      ),
    );

    controller.forward();
  }

  Widget displayBackground() {
    return Container(
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Container(
                padding: EdgeInsets.all(20),
                alignment: Alignment.topCenter,
                child: Container(height: 30, width: 60, color: Colors.red),
              )),
          Expanded(
              flex: 1,
              child: Container(
                color: Colors.green,
                alignment: Alignment.center,
              )),
          Expanded(
              flex: 3,
              child: Container(
                padding: EdgeInsets.all(20),
                alignment: Alignment.topCenter,
                child: Container(height: 30, width: 60, color: Colors.blue),
              )),
        ],
      ),
    );
  }

  Widget displayFirstDraggableItem(GameClassifyModel item) {
    print(item.image);
    Offset position = item.position;
    return AnimatedPositioned(
      top: position.dy,
      left: position.dx,
      curve: Curves.easeOutBack,
      duration: Duration(milliseconds: durationTime),
      child: item.status
          ? Container(
              height: 50,
              width: 50,
              child: SvgPicture.asset(
                'assets/${item.image}',
                fit: BoxFit.contain,
              ),
              )
          : Draggable(
              data: 0,
              child: Container(
                height: 50,
                width: 50,
                child: SvgPicture.asset(
                  'assets/${item.image}',
                  fit: BoxFit.contain,
                ),
              ),
              feedback: Container(
                height: 50,
                width: 50,
                child: SvgPicture.asset(
                  'assets/${item.image}',
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
                    item.status = true;
                  });
                  Timer(Duration(milliseconds: 600), () {
                    for (int idx = item.id + 1; idx < items.length; idx++) {
                      if (!items[idx].status) {
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
                    item.status = true;
                  });
                  Timer(Duration(milliseconds: 600), () {
                    for (int idx = item.id + 1; idx < items.length; idx++) {
                      if (!items[idx].status) {
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
        animation: _transAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _transAnimation.value),
            child: child,
          );
        },
        child: Container(
            child: Stack(
                children: items.map((value) {
          return displayFirstDraggableItem(value);
        }).toList())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [displayBackground(), displayDraggableItem()],
        ),
      ),
    );
  }
}
