import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_test/config/id_config.dart';

class ScratcherTutorial extends StatefulWidget {
  final Offset startPosition;
  final Offset endPosition;
  final double ratio;
  final VoidCallback onCompleted;

  ScratcherTutorial(
      {@required this.startPosition,
      @required this.endPosition,
      this.ratio = 1,
      @required this.onCompleted})
      : super();

  _ScratcherTutorialState createState() => _ScratcherTutorialState();
}

class _ScratcherTutorialState extends State<ScratcherTutorial> {
  Offset position;
  Timer timer;

  @override
  void initState() {
    position = widget.startPosition;
    timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        position = position == widget.startPosition
            ? widget.endPosition
            : widget.startPosition;
      });
    });
    Timer(Duration(milliseconds: 2000),(){
      widget.onCompleted();
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
        duration: Duration(milliseconds: 500),
        child: Container(
          height: 67 * widget.ratio,
          width: 52 * widget.ratio,
          child: SvgPicture.asset(TUTORIAL_IMAGE),
        ));
  }
}
