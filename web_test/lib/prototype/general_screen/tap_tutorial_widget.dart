import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:web_test/config/id_config.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/scale_animation.dart';

class TabTutorialWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onTab;
  final int time;
  final double beginValue;
  final double endValue;
  final bool isScale;
  final Curve curve;
  final int itemId;
  final VoidCallback onCompleted;

  TabTutorialWidget(
      {this.child,
      this.onTab,
      this.time = 300,
      this.beginValue = 1.0,
      this.endValue = 0.7,
      this.isScale = false,
      this.curve = Curves.linear,
      this.itemId = 0,
      this.onCompleted});

  _TabTutorialWidgetState createState() => _TabTutorialWidgetState();
}

class _TabTutorialWidgetState extends State<TabTutorialWidget>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _scaleAnimation;
  ScreenModel screenModel;
  double screenHeight;
  double screenWidth;
  double ratio;

  @override
  void initState() {
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
    _animationController = AnimationController(
        duration: Duration(milliseconds: widget.time), vsync: this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    screenHeight = screenModel.getScreenHeight();
    screenWidth = screenModel.getScreenWidth();
    ratio = screenModel.getRatio();
    _scaleAnimation =
        Tween(begin: widget.beginValue, end: widget.endValue).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.75, curve: widget.curve),
      ),
    );
    _animationController.forward().whenComplete(() {
      _animationController.reverse().whenComplete(() {
        widget.onCompleted();
      });
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if(_animationController!=null){
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
          height: 52 * ratio,
          width: 49 * ratio,
          child: SvgPicture.asset(
            TUTORIAL_IMAGE,
            fit: BoxFit.contain,
          )),
    );
  }
}
