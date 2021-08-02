import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_test/config/id_config.dart';

class TutorialWidget extends StatefulWidget {
  final Offset startPosition;
  final Offset endPosition;
  final double ratio;
  final VoidCallback onCompleted;

  TutorialWidget(
      {@required this.startPosition,
      @required this.endPosition,
      this.ratio = 1,
      @required this.onCompleted})
      : super();

  _TutorialWidgetState createState() => _TutorialWidgetState();
}

class _TutorialWidgetState extends State<TutorialWidget> {
  Offset position;
  Timer timer;

  @override
  void initState() {
    position = widget.startPosition;
    timer = Timer(Duration(milliseconds: 500), () {
      setState(() {
        position = widget.endPosition;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    if (timer != null) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
        top: position.dy,
        left: position.dx,
        duration: Duration(milliseconds: 1000),
        onEnd: () {
          widget.onCompleted();
        },
        child: Container(
          height: 67 * widget.ratio,
          width: 52 * widget.ratio,
          child: SvgPicture.asset(TUTORIAL_IMAGE),
        ));
  }
}
