import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/animation_character_item_paint.dart';

class AnimationCharacterItem extends StatefulWidget {
  AnimationCharacterItem(this.img, this.imgWidth, this.imgHeight,
      this.paintColor, this.path, this._points, this.isPlayAnimation)
      : super();

  final String img;
  final double imgWidth;
  final double imgHeight;
  final Color paintColor;
  final Path path;
  final List<Map> _points;
  final bool isPlayAnimation;

  @override
  _AnimationCharacterItemState createState() => _AnimationCharacterItemState();
}

class _AnimationCharacterItemState extends State<AnimationCharacterItem>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _scaleAnimation;
  bool isFirstTime = true;
  ScreenModel screenModel;

  @override
  void initState() {
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
    _animationController =
        AnimationController(duration: Duration(milliseconds: 700), vsync: this);
    super.initState();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaleAnimation = Tween(
            begin: 5.0,
            end: widget.imgWidth > widget.imgHeight
                ? widget.imgWidth
                : widget.imgHeight)
        .animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.75, curve: Curves.linear),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isPlayAnimation) {
      if (isFirstTime) {
        _animationController.forward();
        setState(() {
          isFirstTime = false;
        });
      }
    }
    return Stack(
      children: [
        SvgPicture.file(File(widget.img),
            height: widget.imgHeight,
            width: widget.imgWidth,
            allowDrawingOutsideViewBox: true),
        AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.imgWidth, widget.imgHeight),
                foregroundPainter: AnimationCharacterItemPaint(
                    widget._points, widget.path, _scaleAnimation.value),
              );
            })
      ],
    );
  }
}
