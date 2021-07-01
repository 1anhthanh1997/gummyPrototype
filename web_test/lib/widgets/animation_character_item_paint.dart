import 'package:flutter/material.dart';
import 'dart:ui';

class AnimationCharacterItemPaint extends CustomPainter {
  AnimationCharacterItemPaint(this._points, this.path, this.pointSize) : super();

  List<Map> _points;
  Path path;
  double pointSize;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipPath(path);
    for (int i = 0; i < _points.length; i++) {
      if(_points[i]!=null){
        canvas.drawCircle(_points[i]['offset'], pointSize, Paint()..color = _points[i]['color']);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

// @override
// bool hitTest(Offset position) {
//   Path path = parseSvgPath(_svgPath);
//   path.close();
//   print(_name + '#' + path.contains(position).toString());
//   return path.contains(position);
// }
}
