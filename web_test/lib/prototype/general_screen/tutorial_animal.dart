import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_test/model/item_model.dart';

class TutorialAnimals extends StatefulWidget {
  final String tutorialImage;

  // String state;
  TutorialAnimals({Key key, this.tutorialImage}) : super(key: key);

  @override
  _TutorialAnimalsState createState() => _TutorialAnimalsState();
}

class _TutorialAnimalsState extends State<TutorialAnimals> {
  Offset currentOffset = Offset(-9, 290);
  int duration = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      top: currentOffset.dy,
      left: currentOffset.dx,
      duration: Duration(milliseconds: duration),
      curve: Curves.easeOutBack,
      child: Draggable(
        child: Container(
          height: 98,
          width: 98,
          child: SvgPicture.asset(
            widget.tutorialImage,
            fit: BoxFit.contain,
          ),
        ),
        feedback: Container(
          height: 98,
          width: 98,
          child: SvgPicture.asset(
            widget.tutorialImage,
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
          if (offset.dx < 357) {
            offsetSource = Offset(-9, 290);
          } else {
            offsetSource = Offset(723, 290);
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
    );
  }
}
