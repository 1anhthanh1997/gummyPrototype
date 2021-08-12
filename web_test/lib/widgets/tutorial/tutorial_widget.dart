import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rive/rive.dart';
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
  bool isDisplayImage = false;

  @override
  void initState() {
    position = widget.startPosition;
    timer = Timer(Duration(milliseconds: 800), () {
      setState(() {
        position = widget.endPosition;
        isDisplayImage = true;
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
          height: isDisplayImage ? 67 * widget.ratio : 67 * widget.ratio * 1.2,
          width: isDisplayImage ? 52 * widget.ratio : 52 * widget.ratio * 1.2,
          child: isDisplayImage
              ? SvgPicture.asset(TUTORIAL_IMAGE)
              : RiveAnimation.asset(
                  'assets/rives/tutorial_rives/tutorial_hand.riv'),
        ));
  }
}
