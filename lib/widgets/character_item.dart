import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_test/widgets/character_item_paint.dart';

class CharacterItem extends StatefulWidget {
  CharacterItem(this.img, this.imgWidth, this.imgHeight, this.paintColor,
      this.path, this._points, this.isCompleted)
      : super();

  final String img;
  final double imgWidth;
  final double imgHeight;
  final Color paintColor;
  final Path path;
  final List<Map> _points;
  final bool isCompleted;

  @override
  _CharacterItemState createState() => _CharacterItemState();
}

class _CharacterItemState extends State<CharacterItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.isCompleted
            ? SvgPicture.asset(widget.img,
                height: widget.imgHeight,
                width: widget.imgWidth,
                color: Colors.red,
                allowDrawingOutsideViewBox: true)
            : SvgPicture.asset(widget.img,
                height: widget.imgHeight,
                width: widget.imgWidth,
                allowDrawingOutsideViewBox: true),
        CustomPaint(
          size: Size(widget.imgWidth, widget.imgHeight),
          foregroundPainter: CharacterItemPaint(widget._points, widget.path),
        )
      ],
    );
  }
}
