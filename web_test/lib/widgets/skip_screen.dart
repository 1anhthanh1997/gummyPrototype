import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/scale_animation.dart';

class SkipScreen extends StatefulWidget {
  _SkipScreenState createState() => _SkipScreenState();
}

class _SkipScreenState extends State<SkipScreen> {
  double screenWidth;
  double screenHeight;
  double ratio;
  ScreenModel screenModel;

  @override
  void initState() {
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    screenWidth = screenModel.getScreenWidth();
    screenHeight = screenModel.getScreenHeight();
    ratio = screenModel.getRatio();
    super.didChangeDependencies();
  }

  Widget dogDraggable() {
    return Stack(
      children: [
        Positioned(
            top: 11 * ratio,
            left: 11 * ratio,
            child: Container(
              height: 77 * ratio,
              width: 77 * ratio,
              child: SvgPicture.asset('assets/images/common/orange_circle.svg'),
            )),
        Positioned(
            top: 0,
            left: 0,
            child: Container(
              height: 98 * ratio,
              width: 98 * ratio,
              child: SvgPicture.asset('assets/images/common/white_circle.svg'),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: -9 * ratio,
        top: screenHeight - 85 * ratio,
        child: ScaleAnimation(
            beginValue: 25.0,
            endValue: 1.0,
            isScale: true,
            time: 1000,
            curve: Curves.easeOut,
            child: Container(
              height: 98 * ratio,
              width: 98 * ratio,
              child: dogDraggable(),
            )));
  }
}
