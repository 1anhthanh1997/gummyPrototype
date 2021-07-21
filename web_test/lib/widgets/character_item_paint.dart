import 'package:flutter/material.dart';
import 'dart:ui';

class CharacterItemPaint extends CustomPainter {
  CharacterItemPaint(this._points, this.path,this.ratio) : super();

  List<Map> _points;
  Path path;
  double ratio;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipPath(path);
    for (int i = 0; i < _points.length - 1; i++) {
      if(_points[i]!=null){
        canvas.drawCircle(_points[i]['offset'], 55*ratio, Paint()..color = _points[i]['color']);
      }
      if (_points[i] != null && _points[i + 1] != null) {
        canvas.drawLine(
            _points[i]['offset'],
            _points[i + 1]['offset'],
            Paint()
              ..color = _points[i]['color']
              ..strokeWidth = 110*ratio);
      }

      // if (_points[i] != null && _points[i + 1] == null) {
      //   canvas.drawCircle(_points[i]['offset'], 10, Paint()..color = _points[i]['color']);
      // }
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
