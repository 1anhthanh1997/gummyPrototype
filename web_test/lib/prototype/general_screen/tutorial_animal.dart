import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web_test/model/item_model.dart';

class TutorialAnimals extends StatefulWidget{
  @override
  _TutorialAnimalsState createState() => _TutorialAnimalsState();
}
class _TutorialAnimalsState extends State<TutorialAnimals> {
  Offset currentOffset = Offset(0, 315);
  int duration=0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: Stack(
              children: [
                AnimatedPositioned(
                  top: currentOffset.dy,
                  left: currentOffset.dx,
                  duration: Duration(milliseconds: duration),
                  curve: Curves.easeOutBack,
                  child: Draggable(
                    child: Container(
                      height: 60,
                      width: 60,
                      child: Image.asset(
                        'assets/images/ring.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    feedback: Container(
                      height: 60,
                      width: 60,
                      child: Image.asset(
                        'assets/images/ring.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    childWhenDragging: Container(),
                    onDragStarted: () {
                      duration = 0;
                    },
                    maxSimultaneousDrags: 1,
                    onDraggableCanceled: (velocity, offset) {
                      Offset offsetSource;
                      if(offset.dx<406){
                        offsetSource = Offset(0,315);
                      }else{
                        offsetSource=Offset(752,315);
                      }

                      currentOffset = offset;
                      setState(() {});
                      Timer(Duration(milliseconds: 50), () {
                        // double denta = screenModel.getBiggerSpace(
                        //     offsetSource, offset);
                        // if (denta < 200 && status == STATUS_NOT_MATCH) {
                        //   denta = 200;
                        // }
                        duration = 400;
                        currentOffset = offsetSource;

                        setState(() {});
                      });
                    },
                  ),
                )
              ],
            )));
  }
}